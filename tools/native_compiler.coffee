esprima = require 'esprima'
escodegen = require 'escodegen'
fs = require 'fs'
util = require '../src/util'
types = require '../src/types'
{c2t} = types
_ = require '../vendor/_.js'
jvm = require '../src/jvm'

"use strict"

# AST traversal helpers

# even though this makes clones of the object before passing them to the visitor,
# the visitor can still modify the original tree if it modifies descendents of
# the current node. we should pick full mutability, or full copying...
traverse = (object, visitor) ->
  newObject =
    if visitor[object.type]
      visitor[object.type].call(null, _.clone(object))
    else if Array.isArray object
      []
    else
      _.clone(object)

  complete = true # are all subexpressions present?

  for key of object
    if (object.hasOwnProperty(key) and key not in ['parent', 'nodeName'])
      child = object[key]
      if (typeof child == 'object' && child != null)
        child.parent = object
        child.nodeName = key
        newChild = traverse(child, visitor)
        if newChild?
          if Array.isArray newObject
            newObject.push newChild
          else
            newObject?[key] = newChild
        else unless Array.isArray newObject
          complete = false

  return if complete then newObject else null

assert_node_type = (obj, type) ->
  throw new Error "Expected type #{type}, got #{obj.type}" unless type is obj.type

# Resolving / typechecking code

jvm.classpath.push "#{__dirname}/../vendor/classes"

class ClassResolver
  package_name = ""
  class_name = ""
  import_map = {}

  @set_package_name: (name) ->
    package_name = util.int_classname name

  @get_package_name: -> package_name

  @add_name: (name) ->
    name = util.int_classname name
    shortname = util.last(name.split '/')
    if import_map[shortname]?
      throw new Error "Conflicting imports: #{name} and #{import_map[shortname]}"
    classfile = jvm.read_classfile name
    classfile? || throw new Error "Could not load #{val} (classpath was #{jvm.classpath}"
    import_map[shortname] = { name: name, file: classfile }
    return classfile

  @resolve: (shortname) ->
    # TODO: handle shortened but still qualified names
    if shortname of import_map
      import_map[shortname]
    else if (classfile = jvm.read_classfile "java/lang/#{shortname}")
      { name: "java/lang/#{shortname}", classfile: classfile }
    else
      throw new Error "Could not resolve #{shortname}"

convert_type = (ext_type) ->
  if ext_type of types.external2internal
    new types.PrimitiveType ext_type
  else if (matches = /([^[]+)(\[\]+)$/.exec ext_type)
    array_prefix = ('[' for i in [0...matches[2].length/2] by 1).join ''
    return c2t array_prefix + convert_type matches[1]
  else
    c2t (ClassResolver.resolve ext_type).name

class Signature
  regex = /^(static\s+)?(\S+)\s+([\w\d$]+)\s*\((.*)\)/

  constructor: (@full_class_name, sig) ->
    groups = regex.exec sig
    @static = groups[1]?
    @ret_type = groups[2]
    @name = groups[3]
    @args =
      for arg in groups[4].split /,\s+/
        [type, name] = arg.split /\s+/
        { type: type, name: name }

  toFullString: ->
    "#{@full_class_name}::#{@toString()}"

  toString: ->
    ret = convert_type @ret_type
    arg_types = (convert_type arg.type for arg in @args)
    "#{@name}(#{arg_types.join ''})#{ret}"

nodeVisitor =
  CallExpression: (obj) ->
    switch obj.callee.name
      when '_package'
        ClassResolver.set_package_name obj.arguments[0].value
      when '_import'
        ClassResolver.add_name obj.arguments[0].value
      when '_class'
        arg = obj.arguments[0]
        assert_node_type arg, 'AssignmentExpression'
        class_name = arg.left.name
        full_name = "#{ClassResolver.get_package_name()}/#{class_name}"
        classfile = ClassResolver.add_name full_name
        for prop in arg.right.properties
          sig = new Signature full_name, prop.key.value
          unless (m = classfile.methods[sig])?
            candidate_sigs = []
            for candidate_sig, candidate of classfile.methods
              if (candidate_sig.indexOf sig.name) != -1
                candidate_sigs.push candidate_sig
            msg = "Could not find method #{sig.toFullString()}."
            if candidate_sigs.length > 0
              msg += " Did you mean #{candidate_sigs.join(", ")}?"
            throw new Error msg
          # cast the flag to a boolean
          (!!m.access_flags.static) == sig.static || throw new Error "Static flag mismatch for method #{sig.toFullString()}"
          prop.key.value = sig.toFullString()
          assert_node_type prop.value, 'FunctionExpression'
          prop.value.params = [type: 'Identifier', name: 'rs']
          prop.value.params.push {type: 'Identifier', name: '_this'} unless sig.static
          Array::push.apply(prop.value.params,
            {type:'Identifier',name:java_arg.name} for java_arg in sig.args)
        return obj
      when '_new'
        obj.callee.name = 'rs.init_object'
        arg = obj.arguments[0]
        arg.value = (convert_type arg.value).toString()
        return obj
      when '_throw'
        obj.callee.name = 'exceptions.java_throw'
        arg = obj.arguments[0]
        arg.value = (convert_type arg.value).toClassString()
        obj.arguments.unshift {type: 'Identifier', name: 'rs'}
        return obj
      else
        return obj
    return

if module? and require?.main == module
  {argv} = require 'optimist'
  tree = traverse(esprima.parse(fs.readFileSync argv._[0]), nodeVisitor)
  console.log escodegen.generate(tree)
