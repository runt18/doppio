_package 'java.io'

_class Console =
  'static String encoding()': -> null
  'static boolean istty()': -> true

_class FileSystem =
  'static FileSystem getFileSystem()': ->
    # TODO: avoid making a new FS object each time this gets called? seems to happen naturally in java/io/File...
    my_sf = rs.curr_frame()
    cache1 = rs.init_object 'java/io/ExpiringCache'
    cache2 = rs.init_object 'java/io/ExpiringCache'
    cache_init = rs.method_lookup({class: 'java/io/ExpiringCache', sig: '<init>()V'})
    rs.push2 cache1, cache2
    cache_init.setup_stack(rs)
    my_sf.runner = ->
      cache_init.setup_stack(rs)
      my_sf.runner = ->
        rv = rs.init_object 'java/io/UnixFileSystem', {
          'java/io/UnixFileSystem/cache': cache1
          'java/io/UnixFileSystem/javaHomePrefixCache': cache2
          'java/io/UnixFileSystem/slash': system_properties['file.separator'].charCodeAt(0)
          'java/io/UnixFileSystem/colon': system_properties['path.separator'].charCodeAt(0)
          'java/io/UnixFileSystem/javaHome': rs.init_string(system_properties['java.home'], true)
        }
        rs.meta_stack().pop()
        rs.push rv
      throw exceptions.ReturnException
    throw exceptions.ReturnException

_class FileOutputStream =
  'void open(String fname)': ->
    _this.$file = fs.openSync fname.jvm2js_str(), 'w'
  'void writeBytes(byte[] bytes, int offset, int len, boolean append)': write_to_file  # OpenJDK version
  'void writeBytes(byte[] bytes, int offset, int len)': write_to_file   # Apple-java version
  'void close0()': ->
    if _this.$file?
      fs.closeSync(_this.$file)
    _this.$file = 'closed'

write_to_file = (rs, _this, bytes, offset, len, append) ->
  exceptions.java_throw rs, 'java/io/IOException', "Bad file descriptor" if _this.$file == 'closed'
  if _this.$file?
    # appends by default in the browser, not sure in actual node.js impl
    fs.writeSync(_this.$file, new Buffer(bytes.array), offset, len)
    return
  rs.print util.chars2js_str(bytes, offset, len)
  if node?
    # For the browser implementation -- the DOM doesn't get repainted
    # unless we give the event loop a chance to spin.
    rs.curr_frame().runner = -> rs.meta_stack().pop()
    throw new exceptions.YieldIOException (cb) -> setTimeout(cb, 0)

_class FileInputStream =
  'int available()': ->
    exceptions.java_throw rs, 'java/io/IOException', "Bad file descriptor" if _this.$file == 'closed'
    return 0 unless _this.$file? # no buffering for stdin
    stats = fs.fstatSync _this.$file
    stats.size - _this.$pos
  'int read()': ->
    exceptions.java_throw rs, 'java/io/IOException', "Bad file descriptor" if _this.$file == 'closed'
    if (file = _this.$file)?
      # this is a real file that we've already opened
      buf = new Buffer((fs.fstatSync file).size)
      bytes_read = fs.readSync(file, buf, 0, 1, _this.$pos)
      _this.$pos++
      return if bytes_read == 0 then -1 else buf.readUInt8(0)
    # reading from System.in, do it async
    data = null # will be filled in after the yield
    rs.curr_frame().runner = ->
      rs.meta_stack().pop()
      rs.push(if data.length == 0 then -1 else data.charCodeAt(0))
    throw new exceptions.YieldIOException (cb) ->
      rs.async_input 1, (byte) ->
        data = byte
        cb()
  'int readBytes(byte[] byte_arr, int offset, int n_bytes)': ->
    exceptions.java_throw rs, 'java/io/IOException', "Bad file descriptor" if _this.$file == 'closed'
    if _this.$file?
      # this is a real file that we've already opened
      pos = _this.$pos
      file = _this.$file
      buf = new Buffer n_bytes
      # if at end of file, return -1.
      if pos >= fs.fstatSync(file).size-1
        return -1
      bytes_read = fs.readSync(file, buf, 0, n_bytes, pos)
      # not clear why, but sometimes node doesn't move the file pointer,
      # so we do it here ourselves
      _this.$pos += bytes_read
      byte_arr.array[offset+i] = buf.readUInt8(i) for i in [0...bytes_read] by 1
      return if bytes_read == 0 and n_bytes isnt 0 then -1 else bytes_read
    # reading from System.in, do it async
    result = null # will be filled in after the yield
    rs.curr_frame().runner = ->
      rs.meta_stack().pop()
      rs.push result
    throw new exceptions.YieldIOException (cb) ->
      rs.async_input n_bytes, (bytes) ->
        byte_arr.array[offset+idx] = b for b, idx in bytes
        result = bytes.length
        cb()
  'void open(String filename)': ->
    filepath = filename.jvm2js_str()
    try  # TODO: actually look at the mode
      _this.$file = fs.openSync filepath, 'r'
      _this.$pos = 0
    catch e
      if e.code == 'ENOENT'
        exceptions.java_throw rs, 'java/io/FileNotFoundException', "Could not open file #{filepath}"
      else
        throw e
  'void close0()': ->
    if _this.$file?
      fs.closeSync _this.$file
    _this.$file = 'closed'
  'long skip(long n_bytes)': ->
    exceptions.java_throw rs, 'java/io/IOException', "Bad file descriptor" if _this.$file == 'closed'
    if (file = _this.$file)?
      bytes_left = fs.fstatSync(file).size - _this.$pos
      to_skip = Math.min(n_bytes.toNumber(), bytes_left)
      _this.$pos += to_skip
      return gLong.fromNumber(to_skip)
    # reading from System.in, do it async
    num_skipped = null # will be filled in after the yield
    rs.curr_frame().runner = ->
      rs.meta_stack().pop()
      rs.push gLong.fromNumber(num_skipped)
    throw new exceptions.YieldIOException (cb) ->
      rs.async_input n_bytes.toNumber(), (bytes) ->
        num_skipped = bytes.length  # we don't care about what the input actually was
        cb()

_class ObjectStreamClass =
  'static void initNative()': ->  # NOP

_class RandomAccessFile =
  'void open(String filename, int mode)': ->
    filepath = filename.jvm2js_str()
    try  # TODO: actually look at the mode
      _this.$file = fs.openSync filepath, 'r'
    catch e
      if e.code == 'ENOENT'
        exceptions.java_throw rs, 'java/io/FileNotFoundException', "Could not open file #{filepath}"
      else
        throw e
    _this.$pos = 0
  'long getFilePointer()': -> gLong.fromNumber _this.$pos
  'long length()': ->
    stats = stat_file _this.$file
    gLong.fromNumber stats.size
  'void seek(long pos)': -> _this.$pos = pos
  'int readBytes(byte[] byte_arr, int offset, int len)': ->
    pos = _this.$pos.toNumber()
    file = _this.$file
    # if at end of file, return -1.
    if pos >= fs.fstatSync(file).size-1
      return -1
    buf = new Buffer len
    bytes_read = fs.readSync(file, buf, 0, len, pos)
    byte_arr.array[offset+i] = buf.readUInt8(i) for i in [0...bytes_read] by 1
    _this.$pos = gLong.fromNumber(pos+bytes_read)
    return if bytes_read == 0 and len isnt 0 then -1 else bytes_read
  'void close0()': ->
    fs.closeSync _this.$file
    _this.$file = null

stat_file = (fname) ->
  try
    if util.is_string(fname) then fs.statSync(fname) else fs.fstatSync(fname)
  catch e
    null

_class UnixFileSystem =
  'String canonicalize0(String jvm_path_str)': ->
    js_str = jvm_path_str.jvm2js_str()
    rs.init_string path.resolve(path.normalize(js_str))
  'boolean checkAccess(File file, int access)': ->
    filepath = file.get_field rs, 'java/io/File/path'
    stats = stat_file filepath.jvm2js_str()
    return false unless stats?
    #XXX: Assuming we're owner/group/other. :)
    # Shift access so it's present in owner/group/other.
    # Then, AND with the actual mode, and check if the result is above 0.
    # That indicates that the access bit we're looking for was set on
    # one of owner/group/other.
    mask = access | (access << 3) | (access << 6)
    return (stats.mode & mask) > 0
  'boolean createDirectory(File file)': ->
    filepath = (file.get_field rs, 'java/io/File/path').jvm2js_str()
    # Already exists.
    return false if stat_file(filepath)?
    try
      fs.mkdirSync(filepath)
    catch e
      return false
    return true
  'boolean createFileExclusively(String path)': ->  # OpenJDK version
    filepath = path.jvm2js_str()
    return false if stat_file(filepath)?
    try
      fs.closeSync fs.openSync(filepath, 'w')  # creates an empty file
    catch e
      exceptions.java_throw rs, 'java/io/IOException', e.message
    true
  'boolean createFileExclusively(String path, boolean unused)': ->  # Apple-java version
    filepath = path.jvm2js_str()
    return false if stat_file(filepath)?
    try
      fs.closeSync fs.openSync(filepath, 'w')  # creates an empty file
    catch e
      exceptions.java_throw rs, 'java/io/IOException', e.message
    true
  'boolean delete0(File file)': ->
    # Delete the file or directory denoted by the given abstract
    # pathname, returning true if and only if the operation succeeds.
    # If file is a directory, it must be empty.
    filepath = (file.get_field rs, 'java/io/File/path').jvm2js_str()
    stats = stat_file filepath
    return false unless stats?
    try
      if stats.isDirectory()
        return false if (fs.readdirSync filepath).length > 0
        fs.rmdirSync(filepath)
      else
        fs.unlinkSync(filepath)
    catch e
      return false
    return true
  'int getBooleanAttributes0(File file)': ->
    filepath = file.get_field rs, 'java/io/File/path'
    stats = stat_file filepath.jvm2js_str()
    return 0 unless stats?
    if stats.isFile() then 3 else if stats.isDirectory() then 5 else 1
  'long getLastModifiedTime(File file)': ->
    filepath = file.get_field(rs, 'java/io/File/path').jvm2js_str()
    stats = stat_file filepath
    return gLong.ZERO unless stats?
    gLong.fromNumber (new Date(stats.mtime)).getTime()
  'long getLength(File file)': ->
    filepath = file.get_field rs, 'java/io/File/path'
    try
      length = fs.statSync(filepath.jvm2js_str()).size
    catch e
      length = 0
    gLong.fromNumber(length)
#o 'getSpace(Ljava/io/File;I)J', (rs, _this, file, t) ->
  'String[] list(File file)': ->
    filepath = file.get_field rs, 'java/io/File/path'
    try
      files = fs.readdirSync(filepath.jvm2js_str())
    catch e
      return null
    rs.init_array('[Ljava/lang/String;',(rs.init_string(f) for f in files))
  'boolean rename0(File file1, File file2)': ->
    file1path = (file1.get_field rs, 'java/io/File/path').jvm2js_str()
    file2path = (file2.get_field rs, 'java/io/File/path').jvm2js_str()
    try
      fs.renameSync(file1path, file2path)
    catch e
      return false
    return true
#o 'setLastModifiedTime(Ljava/io/File;J)Z', (rs, _this, file, time) ->
  'boolean setPermission(File file, int access, boolean enable, boolean owneronly)': ->
    filepath = (file.get_field rs, 'java/io/File/path').jvm2js_str()
    # Access is equal to one of the following static fields:
    # * FileSystem.ACCESS_READ (0x04)
    # * FileSystem.ACCESS_WRITE (0x02)
    # * FileSystem.ACCESS_EXECUTE (0x01)
    # These are conveniently identical to their Unix equivalents, which
    # we have to convert to for Node.
    # XXX: Currently assuming that the above assumption holds across JCLs.

    if owneronly
      # Shift it 6 bits over into the 'owner' region of the access mode.
      access <<= 6
    else
      # Clone it into the 'owner' and 'group' regions.
      access |= (access << 6) | (access << 3)

    if not enable
      # Do an invert and we'll AND rather than OR.
      access = ~access

    # Returns true on success, false on failure.
    try
      # Fetch existing permissions on file.
      stats = stat_file filepath
      return false unless stats?
      existing_access = stats.mode
      # Apply mask.
      access = if enable then existing_access | access else existing_access & access
      # Set new permissions.
      fs.chmodSync filepath, access
    catch e
      return false
    return true
  'boolean setReadOnly(File file)': ->
    filepath = (file.get_field rs, 'java/io/File/path').jvm2js_str()
    # We'll be unsetting write permissions.
    # Leading 0o indicates octal.
    mask = ~(0o222)
    try
      stats = stat_file filepath
      return false unless stats?
      fs.chmodSync filepath, (stats.mode & mask)
    catch e
      return false
    return true
