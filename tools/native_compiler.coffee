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

traverse = (object, visitor) ->
  if visitor[object.type]?
    object = visitor[object.type].call(null, object)
    return unless object?

  unless Array.isArray object
    complete = true
    for key in Object.keys object
      child = object[key]
      if typeof child == 'object' && child != null
        object[key] = traverse(child, visitor)
        complete &= object[key]?
    if complete then object else null
  else
    new_object = []
    for i in [0...object.length] by 1
      child = object[i]
      if typeof child == 'object' && child != null
        new_child = traverse(child, visitor)
        if new_child?
          new_object.push new_child
    new_object

assert_node_type = (obj, type) ->
  throw new Error "Expected type #{type}, got #{obj.type}" unless type is obj.type

ident_or_lit_value = (node) -> node.value ? node.name

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
      if groups[4] is ''
        []
      else
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
        arg = obj.arguments[0]
        assert_node_type arg, 'CallExpression'
        obj.callee.name = 'exceptions.java_throw'
        obj.arguments = [
          {type: 'Identifier', name: 'rs'}
          {type: 'Literal', value: (convert_type arg.callee.name).toClassString()}
        ]
        Array::push.apply obj.arguments, arg.arguments
        return obj
      when '_static'
        arg = obj.arguments[0]
        if arg.type is 'AssignmentExpression'
          obj.callee.name = 'rs.static_put'
          cls_name = arg.left.object.name
          full_name = (ClassResolver.resolve cls_name).name
          obj.arguments[0] = {
            type: 'ObjectExpression'
            properties: [
              {
                type: 'Property'
                key: { type: 'Identifier', name: 'class' }
                value: { type: 'Literal', value: full_name }
                kind: 'init'
              }
              {
                type: 'Property'
                key: { type: 'Identifier', name: 'name' }
                value: { type: 'Literal', value: ident_or_lit_value arg.left.property }
                kind: 'init'
              }
            ]
          }
          return {
            type: 'SequenceExpression'
            expressions: [
              {
                type: 'CallExpression'
                callee: {
                  type: 'Identifier'
                  name: 'rs.push'
                }
                arguments: [ arg.right ]
              }
              obj
            ]
          }
        else
          assert_node_type arg, 'MemberExpression'
          cls_name = arg.object.name
          full_name = (ClassResolver.resolve cls_name).name
          obj.callee.name = 'rs.static_get'
          obj.arguments = [
            {
              type: 'ObjectExpression'
              properties: [
                {
                  type: 'Property'
                  key: { type: 'Identifier', name: 'class' }
                  value: { type: 'Literal', value: full_name }
                  kind: 'init'
                }
                {
                  type: 'Property'
                  key: { type: 'Identifier', name: 'name' }
                  value: { type: 'Literal', value: ident_or_lit_value arg.property }
                  kind: 'init'
                }
              ]
            }
          ]
          return obj
      else
        return obj
    return

if module? and require?.main == module
  {argv} = require 'optimist'
  tree = traverse(esprima.parse(fs.readFileSync argv._[0]), nodeVisitor)
  console.log escodegen.generate(tree)
