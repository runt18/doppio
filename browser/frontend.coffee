
"use strict"

# To be initialized on document load
controller = null
editor = null
jvm_worker = null
update_bar = null

setup_jvm_worker = ->
  jvm_worker = new Worker 'browser/jvm_worker.js'
  jvm_worker.onerror = (e) ->
    throw new Error("#{e.message} (#{e.filename}:#{e.lineno})")
  jvm_worker.onmessage = (event) ->
    msg = JSON.parse event.data
    switch msg.type
      when 'error'
        console.error msg.message
      when 'stdout'
        controller.message msg.str, '', true  # noreprompt
      when 'stdin'
        oldPrompt = controller.promptLabel
        controller.promptLabel = ''
        controller.reprompt()
        oldHandle = controller.commandHandle
        controller.commandHandle = (line) ->
          controller.commandHandle = oldHandle
          controller.promptLabel = oldPrompt
          if line == '\0' # EOF
            jvm_worker.postMessage {type: 'stdin resume', read_bytes: 0}
          else
            line += "\n" # so BufferedReader knows it has a full line
            len = Math.min msg.n_bytes, line.length
            bytes = (line.charCodeAt(i) for i in [0...len] by 1)
            jvm_worker.postMessage {type: 'stdin resume', read_bytes: bytes}
      when 'preload progress'
        update_bar(msg.percent, msg.path)
      when 'preload complete'
        console.log "Untarring took a total of #{msg.elapsed}ms."
        $('#overlay').fadeOut 'slow'
        $('#progress-container').fadeOut 'slow'
        $('#console').click()
      when 'reprompt'
        controller.reprompt()
  jvm_worker.postMessage {type: 'initialize'}

setup_file_uploader = ->
  $('#file').change (ev) ->
    unless FileReader?
      controller.message """
        Your browser doesn't support file loading.
        Try using the editor to create files instead.
        """, "error"
      return $('#console').click() # click to restore focus
    num_files = ev.target.files.length
    files_uploaded = 0
    controller.message "Uploading #{num_files} files...\n", 'success', true
    # Need to make a function instead of making this the body of a loop so we
    # don't overwrite "f" before the onload handler calls.
    file_fcn = ((f) ->
        reader = new FileReader
        reader.onerror = (e) ->
          switch e.target.error.code
            when e.target.error.NOT_FOUND_ERR then alert "404'd"
            when e.target.error.NOT_READABLE_ERR then alert "unreadable"
            when e.target.error.SECURITY_ERR then alert "only works with --allow-file-access-from-files"
        ext = f.name.split('.')[1]
        isClass = ext == 'class'
        reader.onload = (e) ->
          files_uploaded++
          node.fs.writeFileSync(node.process.cwd() + '/' + f.name, e.target.result)
          controller.message "[#{files_uploaded}/#{num_files}] File '#{f.name}' saved.\n", 'success', files_uploaded != num_files
          if isClass
            editor.getSession?().setValue("/*\n * Binary file: #{f.name}\n */")
          else
            editor.getSession?().setValue(e.target.result)
          $('#console').click() # click to restore focus)
        if isClass then reader.readAsBinaryString(f) else reader.readAsText(f)
      )
    for f in ev.target.files
      file_fcn(f)
    return

setup_console = ->
  jqconsole = $('#console')
  controller = jqconsole.console
    promptLabel: 'doppio > '
    commandHandle: (line) ->
      [cmd,args...] = line.trim().split(/\s+/)
      if cmd == '' then return true
      handler = commands[cmd]
      try
        if handler? then handler(a.trim() for a in args when a.length>0)
        else "Unknown command '#{cmd}'. Enter 'help' for a list of commands."
      catch e
        controller.message e.toString(), 'error'
    tabComplete: tabComplete
    autofocus: false
    animateScroll: true
    promptHistory: true
    welcomeMessage: """
      Welcome to Doppio! You may wish to try the following Java programs:
        java classes/test/FileRead
        java classes/demo/Fib <num>
        java classes/demo/Chatterbot
        java classes/demo/RegexTestHarness
        java classes/demo/Lzw c Hello.txt hello.lzw (compress)
        java classes/demo/Lzw d hello.lzw hello (decompress)
        java classes/demo/DiffPrint Hello.txt hello

      We support the stock Sun Java Compiler:
        javac classes/test/FileRead.java
        javac classes/demo/Fib.java

      And we can even run Rhino, the Java-based JS engine!
        rhino

      Text files can be edited by typing `edit [filename]`.

      You can also upload your own files using the uploader above the top-right
      corner of the console.

      Enter 'help' for full a list of commands. Ctrl-D is EOF.
      """

setup_editor = ->
  editor = $('#editor')
  close_editor = ->
    $('#ide').fadeOut 'fast', ->
      $('#console').fadeIn('fast').click() # click to restore focus
  $('#save_btn').click (e) ->
    fname = $('#filename').val()
    contents = editor.getSession().getValue()
    contents += '\n' unless contents[contents.length-1] == '\n'
    node.fs.writeFileSync(fname, contents)
    controller.message("File saved as '#{fname}'.", 'success')
    close_editor()
    e.preventDefault()
  $('#close_btn').click (e) ->
    close_editor()
    e.preventDefault()


$(document).ready ->
  # function to update the UI for the preload progress bar
  update_bar = _.throttle ((percent, path) ->
    bar = $('#progress > .bar')
    preloading_file = $('#preloading-file')
    # +10% hack to make the bar appear fuller before fading kicks in
    display_perc = Math.min Math.ceil(percent*100), 100
    bar.width "#{display_perc}%", 150
    preloading_file.text(
      if display_perc < 100 then "Loading #{path}" else "Done!"))

  # hack for old IE versions
  if $.browser.msie and not window.Blob
    inject_vbscript()

  setup_jvm_worker()
  setup_console()
  setup_file_uploader()
  setup_editor()

commands =
  javac: (args) ->
    jvm_worker.postMessage {type: 'javac', args: args}
    return null  # no reprompt, because we handle it ourselves
  java: (args) ->
    if !args[0]? or (args[0] == '-classpath' and args.length < 3)
      return "Usage: java [-classpath path1:path2...] class [args...]"
    jvm_worker.postMessage {type: 'java', args: args}
    return null  # no reprompt, because we handle it ourselves
  test: (args) ->
    return "Usage: test all|[class(es) to test]" unless args[0]?
    jvm_worker.postMessage {type: 'test', args: args}
    return null
  javap: (args) ->
    return "Usage: javap class" unless args[0]?
    jvm_worker.postMessage {type: 'javap', args: args}
    return null  # no reprompt, because we handle it ourselves
  rhino: (args) ->
    jvm_worker.postMessage {type: 'rhino', args: args}
    return null  # no reprompt, because we handle it ourselves
  list_cache: ->
    jvm_worker.postMessage {type: 'list_cache'}
    return ''
  clear_cache: ->
    jvm_worker.postMessage {type: 'clear_cache'}
    return "Cache cleared."
  ls: (args) ->
    read_dir = (dir) -> node.fs.readdirSync(dir).sort().join '\n'
    if args.length == 0
      read_dir '.'
    else if args.length == 1
      read_dir args[0]
    else
      ("#{d}:\n#{read_dir d}\n" for d in args).join '\n'
  edit: (args) ->
    try
      data = if args[0]? then node.fs.readFileSync(args[0]) else defaultFile
    catch e
      data = defaultFile
    $('#console').fadeOut 'fast', ->
      $('#filename').val args[0]
      $('#ide').fadeIn('fast')
      # initialize the editor. technically we only need to do this once, but more
      # than once is fine too
      editor = ace.edit('source')
      editor.setTheme 'ace/theme/twilight'
      ext = args[0]?.split('.')[1]
      if ext is 'java' or not args[0]?
        JavaMode = require("ace/mode/java").Mode
        editor.getSession().setMode(new JavaMode)
      else
        TextMode = require("ace/mode/text").Mode
        editor.getSession().setMode(new TextMode)
      editor.getSession().setValue(data)
    true
  cat: (args) ->
    fname = args[0]
    return "Usage: cat <file>" unless fname?
    try
      return node.fs.readFileSync(fname)
    catch e
      return "ERROR: #{fname} does not exist."
  mv: (args) ->
    if args.length < 2 then return "Usage: mv <from-file> <to-file>"
    try
      node.fs.renameSync(args[0], args[1])
    catch e
      return "Invalid arguments."
    true
  cd: (args) ->
    if args.length > 1 then return "Usage: cd <directory>"
    if args.length == 0 then args.push("~")
    try
      node.process.chdir(args[0])
    catch e
      return "Invalid directory."
    true
  rm: (args) ->
    return "Usage: rm <file>" unless args[0]?
    if args[0] == '*'
      fnames = node.fs.readdirSync('.')
      for fname in fnames
        fstat = node.fs.statSync(fname)
        if fstat.is_directory
          return "ERROR: '#{fname}' is a directory."
        node.fs.unlinkSync(fname)
    else node.fs.unlinkSync args[0]
    true
  emacs: -> "Try 'vim'."
  vim: -> "Try 'emacs'."
  time: (args) ->
    start = (new Date).getTime()
    console.profile args[0]
    controller.onreprompt = ->
      controller.onreprompt = null
      console.profileEnd()
      end = (new Date).getTime()
      controller.message "\nCommand took a total of #{end-start}ms to run.\n", '', true
    commands[args.shift()](args)
  profile: (args) ->
    count = 0
    runs = 5
    duration = 0
    time_once = ->
      start = (new Date).getTime()
      controller.onreprompt = ->
        unless count < runs
          controller.onreprompt = null
          controller.message "\n#{args[0]} took an average of #{duration/runs}ms.\n", '', true
          return
        end = (new Date).getTime()
        if count++ == 0 # first one to warm the cache
          return time_once()
        duration += end - start
        time_once()
      commands[args.shift()](args)
    time_once()
  help: (args) ->
    """
    Ctrl-D is EOF.

    Java-related commands:
      javac <source file>    -- Invoke the Java 6 compiler.
      java <class> [args...] -- Run with command-line arguments.
      javap <class>          -- Display disassembly.
      time                   -- Measure how long it takes to run a command.

    File management:
      cat <file>             -- Display a file in the console.
      edit <file>            -- Edit a file.
      ls <dir>               -- List files.
      mv <src> <dst>         -- Move / rename a file.
      rm <file>              -- Delete a file.
      cd <dir>               -- Change current directory.

    Cache management:
      list_cache             -- List the cached class files.
      clear_cache            -- Clear the cached class files.
    """

tabComplete = ->
  promptText = controller.promptText()
  args = promptText.split /\s+/
  getCompletions = (args) ->
    if args.length is 1 then commandCompletions args[0]
    else if args[0] is 'time' then getCompletions(args[1..])
    else fileNameCompletions args[0], args
  prefix = longestCommmonPrefix(getCompletions(args))
  return if prefix == ''  # TODO: if we're tab-completing a blank, show all options
  # delete existing text so we can do case correction
  promptText = promptText.substr(0, promptText.length - args[args.length-1].length)
  controller.promptText(promptText + prefix)

commandCompletions = (cmd) ->
  (name for name, handler of commands when name.substr(0, cmd.length) is cmd)

fileNameCompletions = (cmd, args) ->
  validExtension = (fname) ->
    dot = fname.lastIndexOf('.')
    ext = if dot is -1 then '' else fname.slice(dot+1)
    if cmd is 'javac' then ext is 'java'
    else if cmd is 'javap' or cmd is 'java' then ext is 'class'
    else true
  chopExt = args.length == 2 and (cmd is 'javap' or cmd is 'java')
  toComplete = args[args.length-1]
  lastSlash = toComplete.lastIndexOf('/')
  if lastSlash >= 0
    dirPfx = toComplete.slice(0, lastSlash+1)
    searchPfx = toComplete.slice(lastSlash+1)
  else
    dirPfx = ''
    searchPfx = toComplete
  try
    dirList = node.fs.readdirSync(if dirPfx == '' then '.' else dirPfx)
    # Slight cheat.
    dirList.push('..')
    dirList.push('.')
  catch e
    return []

  completions = []
  for item in dirList
    isDir = node.fs.statSync(dirPfx + item)?.isDirectory()
    continue unless validExtension(item) or isDir
    if item.slice(0, searchPfx.length) == searchPfx
      if isDir
        completions.push(dirPfx + item + '/')
      else if cmd != 'cd'
        completions.push(dirPfx + (if chopExt then item.split('.',1)[0] else item))
  completions

# use the awesome greedy regex hack, from http://stackoverflow.com/a/1922153/10601
longestCommmonPrefix = (lst) -> lst.join(' ').match(/^(\S*)\S*(?: \1\S*)*$/i)[1]

defaultFile =
  """
  class Test {
    public static void main(String[] args) {
      // enter code here
    }
  }
  """
