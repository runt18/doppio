_ = require '../vendor/_.js'
gLong = require '../vendor/gLong.js'
util = require './util'
types = require './types'
runtime = require './runtime'
{thread_name,JavaObject,JavaArray} = require './java_object'
exceptions = require './exceptions'
{log,debug,error} = require './logging'
path = node?.path ? require 'path'
fs = node?.fs ? require 'fs'
{c2t} = types

"use strict"

# things assigned to root will be available outside this module
root = exports ? this.natives = {}

if node?  # node is only defined if we're in the browser
  vendor_path ='/home/doppio/vendor'
else
  vendor_path = path.resolve __dirname, '../vendor'

# this gets filled in by the native compiler
root.native_methods = {}
root.trapped_methods = {}
