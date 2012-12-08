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
  unless Array.isArray object
    if visitor.pre[object.type]?
      object = visitor.pre[object.type].call(null, object)
      return unless object?

    complete = true
    for key in Object.keys object
      child = object[key]
      if typeof child == 'object' && child != null
        object[key] = traverse(child, visitor)
        complete &= object[key]?

    if visitor.post[object.type]?
      object = visitor.post[object.type].call(null, object)

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

class CompileError
  constructor: (@node, @msg) ->
    @stack = (new Error).stack.split('\n')[2..].join '\n'

  toString: -> "Line #{@node.loc?.start.line}: #{@msg}\n#{@stack}"

assert_node_type = (obj, type) ->
  throw new CompileError obj, "Expected type #{type}, got #{obj.type}" unless type is obj.type

member_value = (node) -> node.value ? node.name

ident = (str) -> type: 'Identifier', name: str

lit = (str) -> type: 'Literal', value: str

stmt = (node) -> type: 'ExpressionStatement', expression: node

# Resolving / typechecking code

jvm.classpath.push "#{__dirname}/../vendor/classes"

class ClassResolver
  constructor: (@package_name) ->
    @class_name = ""
    @import_map = {}

  add_name: (name) ->
    name = util.int_classname name
    shortname = util.last(name.split '/')
    if @import_map[shortname]?
      throw new Error "Conflicting imports: #{name} and #{@import_map[shortname]}"
    classfile = jvm.read_classfile name
    classfile? || throw new Error "Could not load #{val} (classpath was #{jvm.classpath}"
    @import_map[shortname] = { name: name, file: classfile }
    return classfile

  resolve: (shortname) ->
    # TODO: handle shortened but still qualified names
    if shortname of @import_map
      @import_map[shortname]
    else if (classfile = jvm.read_classfile "java/lang/#{shortname}")
      { name: "java/lang/#{shortname}", classfile: classfile }
    else
      throw new Error "Could not resolve #{shortname}"

convert_type = (ext_type, resolver) ->
  if ext_type of types.external2internal
    new types.PrimitiveType ext_type
  else if (matches = /([^[]+)(\[\]+)$/.exec ext_type)
    array_prefix = ('[' for i in [0...matches[2].length/2] by 1).join ''
    return c2t array_prefix + convert_type matches[1], resolver
  else
    c2t (resolver.resolve ext_type).name

class Signature
  regex = /^(static\s+)?(\S+)\s+([\w\d$]+)\s*\((.*)\)/

  constructor: (@full_class_name, sig, @resolver) ->
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
    ret = convert_type @ret_type, @resolver
    arg_types = (convert_type(arg.type, @resolver) for arg in @args)
    "#{@name}(#{arg_types.join ''})#{ret}"

class NodeVisitor
  resolver = null
  methods = []

  @get_methods: -> methods

  @pre:
    CallExpression: (obj) ->
      switch obj.callee.name
        when '_package'
          resolver = new ClassResolver obj.arguments[0].value
        when '_import'
          resolver.add_name obj.arguments[0].value
        when '_class'
          arg = obj.arguments[0]
          assert_node_type arg, 'AssignmentExpression'
          class_name = arg.left.name
          full_name = "#{resolver.package_name}/#{class_name}"
          classfile = resolver.add_name full_name
          for prop in arg.right.properties
            sig = new Signature full_name, prop.key.value, resolver
            unless (m = classfile.methods[sig])?
              candidate_sigs = []
              for candidate_sig, candidate of classfile.methods
                if (candidate_sig.indexOf sig.name) != -1
                  candidate_sigs.push candidate_sig
              msg = "Could not find method #{sig.toFullString()}."
              if candidate_sigs.length > 0
                msg += " Did you mean #{candidate_sigs.join(", ")}?"
              throw new CompileError prop, msg
            # cast the flag to a boolean
            unless (!!m.access_flags.static) == sig.static
              throw new CompileError prop, "Static flag mismatch for method #{sig.toFullString()}"
            prop.key.value = sig.toFullString()
            assert_node_type prop.value, 'FunctionExpression'
            prop.value.params = [ident 'rs']
            prop.value.params.push ident '_this' unless sig.static
            Array::push.apply(prop.value.params,
              ident java_arg.name for java_arg in sig.args)
          Array::push.apply methods, arg.right.properties
          return obj
        when '_new'
          arg = obj.arguments[0]
          obj_type = convert_type arg.value, resolver
          arg.value = (obj_type).toString()
          if obj_type instanceof types.ArrayType
            obj.callee.name = 'rs.init_array'
          else
            obj.callee.name = 'rs.init_object'
          return obj
        when '_throw'
          arg = obj.arguments[0]
          assert_node_type arg, 'CallExpression'
          obj.callee.name = 'exceptions.java_throw'
          obj.arguments = [
            ident 'rs'
            lit (convert_type arg.callee.name, resolver).toClassString()
          ]
          Array::push.apply obj.arguments, arg.arguments
          return obj
        when '_static'
          arg = obj.arguments[0]
          if arg.type is 'AssignmentExpression'
            obj.callee.name = 'rs.static_put'
            cls_name = arg.left.object.name
            full_name = (resolver.resolve cls_name).name
            obj.arguments[0] = {
              type: 'ObjectExpression'
              properties: [
                {
                  type: 'Property'
                  key: ident 'class'
                  value: lit full_name
                  kind: 'init'
                }
                {
                  type: 'Property'
                  key: ident 'name'
                  value: lit member_value arg.left.property
                  kind: 'init'
                }
              ]
            }
            return {
              type: 'SequenceExpression'
              expressions: [
                {
                  type: 'CallExpression'
                  callee: ident 'rs.push'
                  arguments: [ arg.right ]
                }
                obj
              ]
            }
          else
            assert_node_type arg, 'MemberExpression'
            cls_name = arg.object.name
            full_name = (resolver.resolve cls_name).name
            obj.callee.name = 'rs.static_get'
            obj.arguments = [
              type: 'ObjectExpression'
              properties: [
                {
                  type: 'Property'
                  key: ident 'class'
                  value: lit full_name
                  kind: 'init'
                }
                {
                  type: 'Property'
                  key: ident 'name'
                  value: lit member_value arg.property
                  kind: 'init'
                }
              ]
            ]
            return obj
        else
          return obj
      return

  @post:
    CallExpression: (obj) ->
      switch obj.callee.name
        when '_class'
          null
        else
          obj


compile = (file_list) ->

  stmts = []

  for file in file_list
    tree = traverse esprima.parse((fs.readFileSync file), loc:true), NodeVisitor
    Array::push.apply stmts, tree.body

  stmts.push stmt {
    type: 'AssignmentExpression'
    left: ident 'native_methods'
    operator: '='
    right: {
      type: 'ObjectExpression'
      properties: NodeVisitor.get_methods()
    }
  }

  escodegen.generate(type: 'Program', body: stmts)

if module? and require?.main == module
  {argv} = require 'optimist'
  console.log compile argv._
