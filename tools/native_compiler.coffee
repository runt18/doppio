esprima = require 'esprima'
escodegen = require 'escodegen'
fs = require 'fs'
util = require '../src/util'
types = require '../src/types'
_ = require '../vendor/_.js'

convert_type = (ext_type) ->
  if ext_type of types.external2internal
    types.external2internal[ext_type]
  else if ext_type of import_map
    "L#{util.int_classname import_map[ext_type]};"

assert_type = (obj, type) ->
  throw new Error "Expected type #{type}, got #{obj.type}" unless type is obj.type

class Signature
  regex = /^(\w+)\s+([\w\d$]+)\s*\((.*)\)/

  constructor: (@package_name, @class_name, sig) ->
    groups = regex.exec sig
    @ret_type = groups[1]
    @name = groups[2]
    @args =
      for arg in groups[3].split /,\s+/
        [type, name] = arg.split /\s+/
        { type: type, name: name }

  toString: ->
    ret = convert_type @ret_type
    arg_types = (convert_type arg.type for arg in @args)
    "#{util.int_classname @package_name}/#{@class_name}::#{@name}(#{arg_types.join ''})#{ret}"

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

package_name = ""
class_name = ""
import_map = {}

nodeVisitor =
  CallExpression: (obj) ->
    switch obj.callee.name
      when '_package'
        package_name = obj.arguments[0].value
      when '_import'
        val = obj.arguments[0].value
        import_map[util.last(val.split '.')] = val
      when '_class'
        arg = obj.arguments[0]
        assert_type arg, 'AssignmentExpression'
        class_name = arg.left.name
        for prop in arg.right.properties
          sig = new Signature package_name, class_name, prop.key.value
          prop.key.value = sig.toString()
          assert_type prop.value, 'FunctionExpression'
          prop.value.params = [type: 'Identifier', name: 'rs']
          Array::push.apply(prop.value.params,
            {type:'Identifier',name:java_arg.name} for java_arg in sig.args)
        return obj
      else
        return obj
    return

if module? and require?.main == module
  {argv} = require 'optimist'
  tree = traverse(esprima.parse(fs.readFileSync argv._[0]), nodeVisitor)
  console.log escodegen.generate(tree)
