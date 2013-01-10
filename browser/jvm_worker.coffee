
"use strict"

class_cache = {}
raw_cache = {}

basename = (path) -> path.split('/').pop()
self.require = (path) ->
  [name, ext] = basename(path).split '.'
  unless self[name]?
    # XXX: assumes that all new requires are in src
    importScripts("/src/#{name}.js")
  return self[name]

# magic invocation to get access to required external JS
importScripts('node.js')
importScripts('/vendor/gLong.js', '/vendor/_.js')
importScripts('/src/util.js', '/src/ClassFile.js', '/src/jvm.js', '/src/testing.js')


# copypasta from untar.coffee, because imports are hard
untar = (bytes, cb, done_cb) ->
  next_file = ->
    [path,body] = shift_file(bytes)
    percent = bytes.pos() / bytes.size()
    cb percent, path, body
    if bytes.peek() != 0
      next_file()
    else
      done_cb?()
  next_file()

shift_file = (bytes) ->
  header = bytes.read(512)
  fname = util.bytes2str header[0...100]
  size = octal2num header[124...124+11]
  prefix = util.bytes2str header[345...345+155]
  fullname = if prefix then "#{prefix}/#{fname}" else fname

  body = bytes.read(Math.ceil(size/512)*512)
  file = body[0...size]
  [fullname, file]

octal2num = (bytes) ->
  num = 0
  msd = bytes.length - 1
  for b, idx in bytes
    digit = parseInt String.fromCharCode b
    num += digit * Math.pow 8, (msd - idx)
  num
# end copypasta


postJSON = (message) =>
  @postMessage JSON.stringify message

preload = ->
  data = node.fs.readFileSync("/home/doppio/browser/mini-rt.tar")

  return unless data?
  file_count = 0
  done = false
  start_untar = (new Date).getTime()
  on_complete = ->
    postJSON 
      type: 'preload complete'
      elapsed: (new Date).getTime() - start_untar

  untar_cb = (percent, path, file) ->
    postJSON {type: 'preload progress', percent: percent, path: path}
    raw_cache[path] = file
    base_dir = 'vendor/classes/'
    [base,ext] = path.split('.')
    unless ext is 'class'
      on_complete() if percent == 100
      return
    file_count++
    cls = base.substr(base_dir.length)
    # XXX: We convert from bytestr to array to process the tar file, and
    #      then back to a bytestr to store as a file in the filesystem.
    node.fs.writeFileSync(path, util.array_to_bytestr(file), true)
    class_cache[cls] = new ClassFile file
    on_complete() if --file_count == 0 and done
  untar_done_cb = ->
    done = true
    on_complete() if file_count == 0
  untar new util.BytesArray(util.bytestr_to_array data), untar_cb, untar_done_cb

fetch_rhino = ->
  data = node.fs.readFileSync("/home/doppio/vendor/classes/com/sun/tools/script/shell/Main.class")

  if data?
    class_cache['!rhino'] = process_bytecode data

try_path = (path) ->
  try
    return util.bytestr_to_array node.fs.readFileSync(path)
  catch e
    return null

# Read in a binary classfile synchronously. Return an array of bytes.
read_classfile = (cls) ->
  unless class_cache[cls]?
    for path in jvm.classpath
      fullpath = "#{path}#{cls}.class"
      if fullpath of raw_cache
        continue if raw_cache[fullpath] == null # we tried this path previously & it failed
        class_cache[cls] = new ClassFile raw_cache[fullpath]
        break
      raw_cache[fullpath] = try_path fullpath
      if raw_cache[fullpath]?
        class_cache[cls] = new ClassFile raw_cache[fullpath]
        break
  class_cache[cls]

process_bytecode = (bytecode_string) ->
  bytes_array = util.bytestr_to_array bytecode_string
  new ClassFile(bytes_array)

stdout = (str) -> postJSON {type: 'stdout', str: str}

current_stdin_resume = null  # placeholder for resume function
user_input = (n_bytes, resume) ->
  current_stdin_resume = resume
  postJSON {type: 'stdin', n_bytes: n_bytes}
  # after this, nothing else to do until the 'stdin resume' event is received

reprompt = -> postJSON {type: 'reprompt'}

@onmessage = (event) ->
  console.log 'Worker got message: ', event.data
  switch event.data.type
    when 'initialize'
      preload()
      fetch_rhino()
    when 'stdin resume'
      current_stdin_resume event.data.read_bytes
      current_stdin_resume = null  # just to make sure it doesn't get called twice
    when 'javac'
      jvm.classpath = [ "./", "/home/doppio/vendor/classes/", "/home/doppio" ]
      rs = new runtime.RuntimeState(stdout, user_input, read_classfile)
      jvm.run_class(rs, 'classes/util/Javac', event.data.args, reprompt)
    when 'java'
      args = event.data.args
      if args[0] == '-classpath'
        jvm.classpath = args[1].split(':')
        jvm.classpath.push "/home/doppio/vendor/classes/"
        class_name = args[2]
        class_args = args[3..]
      else
        jvm.classpath = [ "./", "/home/doppio/vendor/classes/" ]
        class_name = args[0]
        class_args = args[1..]
      rs = new runtime.RuntimeState(stdout, user_input, read_classfile)
      jvm.run_class(rs, class_name, class_args, reprompt)
    when 'test'
      args = event.data.args
      if args[0] == 'all'
        testing.run_tests [], stdout, true, false, true, reprompt
      else
        testing.run_tests args, stdout, true, false, true, reprompt
    when 'javap'
      arg = event.data.args[0]
      try
        raw_data = node.fs.readFileSync("#{arg}.class")
      catch e
        stdout "Could not find class '#{arg}'."
        return
      disassembler.disassemble process_bytecode raw_data
    when 'rhino'
      args = event.data.args
      jvm.classpath = [ "./", "/home/doppio/vendor/classes/" ]
      rs = new runtime.RuntimeState(stdout, user_input, read_classfile)
      jvm.run_class(rs, '!rhino', args, reprompt)
    when 'list_cache'
      cache_names = ((if val? then '' else '-') + name for name, val of raw_cache)
      stdout cache_names.join('\n') + '\n'
    when 'clear_cache'
      # TODO: provide an option only blast specific classes
      raw_cache = {}
      class_cache = {}
