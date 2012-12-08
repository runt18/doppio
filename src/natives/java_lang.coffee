_package 'java.lang'

_import 'java.lang.reflect.Field'
_import 'java.lang.reflect.Method'
_import 'java.lang.reflect.Constructor'
_import 'java.security.ProtectionDomain'
_import 'sun.reflect.ConstantPool'

system_properties = {
  'java.home': "#{vendor_path}/java_home",
  'sun.boot.class.path': "#{vendor_path}/classes",
  'file.encoding':'US_ASCII','java.vendor':'DoppioVM',
  'java.version': '1.6', 'java.vendor.url': 'https://github.com/int3/doppio',
  'java.class.version': '50.0',
  'line.separator':'\n', 'file.separator':'/', 'path.separator':':',
  'user.dir': path.resolve('.'),'user.home':'.','user.name':'DoppioUser',
  'os.name':'Doppio', 'os.arch': 'js', 'os.version': '0',
  'java.awt.headless': (not node?).toString(),  # true if we're using the console frontend
  'java.awt.graphicsenv': 'classes.awt.CanvasGraphicsEnvironment',
  'useJavaUtilZip': 'true'  # hack for sun6javac, avoid ZipFileIndex shenanigans
}

_class Class =
  'static Class getPrimitiveClass(String jvm_str)': ->
    rs.jclass_obj new types.PrimitiveType(jvm_str.jvm2js_str()), true
  'ClassLoader getClassLoader0()': (rs, _this) -> rs.class_states[_this.type.toClassString()].loader
  'static boolean desiredAssertionStatus0(Class cls)': -> false # we don't need no stinkin asserts
  'String getName0()': (rs, _this) ->
    rs.init_string(_this.$type.toExternalString())
  'static Class forName0(String jvm_str, boolean initialize, ClassLoader loader)': ->
    type = c2t util.int_classname jvm_str.jvm2js_str()
    if loader is null
      rv = rs.jclass_obj type, true
      rs.class_lookup type, true if initialize
      return rv
    # user-defined classloader
    my_sf = rs.curr_frame()
    rs.push2 loader, jvm_str
    rs.method_lookup(
      class: loader.type.toClassString(),
      sig: 'loadClass(Ljava/lang/String;)Ljava/lang/Class;').setup_stack(rs)
    my_sf.runner = ->
      rv = rs.pop()
      rs.meta_stack().pop()
      rs.push rv
      rs.class_lookup type, true if initialize
    throw exceptions.ReturnException
  'Class getComponentType()': ->
    type = _this.$type
    return null unless (type instanceof types.ArrayType)
    rs.jclass_obj type.component_type, true
  'String getGenericSignature()': ->
    sig = _.find(_this.file.attrs, (a) -> a.constructor.name is 'Signature')?.sig
    if sig? then rs.init_string sig else null
  'ProtectionDomain getProtectionDomain0()': -> null
  'boolean isAssignableFrom(Class cls)': ->
    types.is_castable rs, cls.$type, _this.$type
  'boolean isInterface()': ->
    return false unless _this.$type instanceof types.ClassType
    _this.file.access_flags.interface
  'boolean isInstance(Object obj)': ->
    return types.is_castable rs, obj.type, _this.$type
  'boolean isPrimitive()': ->
    _this.$type instanceof types.PrimitiveType
  'boolean isArray()': ->
    _this.$type instanceof types.ArrayType
  'Class getSuperclass()': ->
    return null if _this.$type instanceof types.PrimitiveType
    cls = _this.file
    if cls.access_flags.interface or not cls.super_class?
      return null
    rs.jclass_obj cls.super_class, true
  'Field[] getDeclaredFields0(boolean public_only)': ->
    fields = _this.file.fields
    fields = (f for f in fields when f.access_flags.public) if public_only
    rs.init_array('[Ljava/lang/reflect/Field;',(f.reflector(rs) for f in fields))
  'Method[] getDeclaredMethods0(boolean public_only)': ->
    methods = _this.file.methods
    methods = (m for sig, m of methods when sig[0] != '<' and (m.access_flags.public or not public_only))
    rs.init_array('[Ljava/lang/reflect/Method;',(m.reflector(rs) for m in methods))
  'Constructor[] getDeclaredConstructors0(boolean public_only)': ->
    methods = _this.file.methods
    methods = (m for sig, m of methods when m.name is '<init>')
    methods = (m for m in methods when m.access_flags.public) if public_only
    rs.init_array('[Ljava/lang/reflect/Constructor;',(m.reflector(rs,true) for m in methods))
  'Class[] getInterfaces()': ->
    cls = _this.file
    ifaces = (cls.constant_pool.get(i).deref() for i in cls.interfaces)
    ifaces = ((if util.is_string(i) then c2t(i) else i) for i in ifaces)
    iface_objs = (rs.jclass_obj(iface, true) for iface in ifaces)
    rs.init_array('[Ljava/lang/Class;',iface_objs)
  'int getModifiers()': -> _this.file.access_byte
  'byte[] getRawAnnotations()': ->
    cls = _this.file
    annotations = _.find(cls.attrs, (a) -> a.constructor.name == 'RuntimeVisibleAnnotations')
    return new JavaArray rs, c2t('[B'), annotations.raw_bytes if annotations?
    for sig,m of cls.methods
      annotations = _.find(m.attrs, (a) -> a.constructor.name == 'RuntimeVisibleAnnotations')
      return new JavaArray rs, c2t('[B'), annotations.raw_bytes if annotations?
    null
  'ConstantPool getConstantPool()': ->
    cls = _this.file
    rs.init_object 'sun/reflect/ConstantPool', {'sun/reflect/ConstantPool/constantPoolOop': cls.constant_pool}
  'Object[] getEnclosingMethod0()': ->
    return null unless _this.$type instanceof types.ClassType
    cls = _this.file
    em = _.find(cls.attrs, (a) -> a.constructor.name == 'EnclosingMethod')
    return null unless em?
    exceptions.java_throw rs, 'java/lang/Error', "native method not finished: java.lang.Class.getEnclosingClass"
    #TODO: return array w/ 3 elements:
    # - the immediately enclosing class (java/lang/Class)
    # - the immediately enclosing method or constructor's name (can be null). (String)
    # - the immediately enclosing method or constructor's descriptor (null iff name is). (String)
    #new JavaArray rs, c2t('[Ljava/lang/Object;'), [null,null,null]
  'Class getDeclaringClass()': ->
    return null unless _this.$type instanceof types.ClassType
    cls = _this.file
    icls = _.find(cls.attrs, (a) -> a.constructor.name == 'InnerClasses')
    return null unless icls?
    my_class = _this.$type.toClassString()
    for entry in icls.classes when entry.outer_info_index > 0
      name = cls.constant_pool.get(entry.inner_info_index).deref()
      continue unless name is my_class
      # XXX(jez): this assumes that the first enclosing entry is also
      # the immediate enclosing parent, and I'm not 100% sure this is
      # guaranteed by the spec
      declaring_name = cls.constant_pool.get(entry.outer_info_index).deref()
      return rs.jclass_obj c2t(declaring_name), true
    return null
  'Class[] getDeclaredClasses0()': ->
    ret = new JavaArray rs, c2t('[Ljava/lang/Class;'), []
    return ret unless _this.$type instanceof types.ClassType
    cls = _this.file
    my_class = _this.$type.toClassString()
    iclses = (a for a in cls.attrs when a.constructor.name is 'InnerClasses')
    for icls in iclses
      for c in icls.classes when c.outer_info_index > 0
        enclosing_name = cls.constant_pool.get(c.outer_info_index).deref()
        continue unless enclosing_name is my_class
        name = cls.constant_pool.get(c.inner_info_index).deref()
        ret.array.push rs.jclass_obj c2t(name), true
    ret

_class ClassLoader =
  'Class findLoadedClass0(String name)': ->
    type = c2t util.int_classname name.jvm2js_str()
    rv = null
    try
      rv = rs.jclass_obj type, true
    catch e
      unless e instanceof exceptions.JavaException # assuming a NoClassDefFoundError
        throw e
    rv
  'Class findBootstrapClass(String name)': ->
    type = c2t util.int_classname name.jvm2js_str()
    rs.jclass_obj type, true
  'static Class getCaller(int i)': ->
    type = rs.meta_stack().get_caller(i).method.class_type
    rs.jclass_obj(type, true)
  'Class defineClass1(String name, byte[] bytes, int offset, int len, ProtectionDomain pd, String source, boolean unused)': ->
    native_define_class rs, name, bytes, offset, len, _this
  'Class defineClass1(String name, byte[] bytes, int offset, int len, ProtectionDomain pd, String source)': ->
    native_define_class rs, name, bytes, offset, len, _this
  'void resolveClass0(Class cls)': ->
    rs.load_class cls.$type, true

_class Compiler =
  'static void disable()': -> #NOP
  'static void enable()': -> #NOP

_class Float =
  'static int floatToRawIntBits(float f_val)': ->
    f_view = new Float32Array [f_val]
    i_view = new Int32Array f_view.buffer
    i_view[0]
  'static float intBitsToFloat(int i_val)': ->
    i_view = new Int32Array [i_val]
    f_view = new Float32Array i_view.buffer
    f_view[0]

_class Double =
  'static long doubleToRawLongBits(double d_val)': ->
    d_view = new Float64Array [d_val]
    i_view = new Uint32Array d_view.buffer
    gLong.fromBits i_view[0], i_view[1]
  'static double longBitsToDouble(long l_val)': ->
    i_view = new Uint32Array 2
    i_view[0] = l_val.getLowBitsUnsigned()
    i_view[1] = l_val.getHighBits()
    d_view = new Float64Array i_view.buffer
    d_view[0]

_class Object =
  'Class getClass()': ->
    rs.jclass_obj _this.type, false
  'int hashCode()': ->
    # return the pseudo heap reference, essentially a unique id
    _this.ref
  'Object clone()': -> _this.clone(rs)
  'void notify()': ->
    debug "TE(notify): on lock *#{_this.ref}"
    if (locker = rs.lock_refs[_this])?
      if locker isnt rs.curr_thread
        owner = thread_name rs, locker
        exceptions.java_throw rs, 'java/lang/IllegalMonitorStateException', "Thread '#{owner}' owns this monitor"
    if rs.waiting_threads[_this]?
      rs.waiting_threads[_this].shift()
  'void notifyAll()': ->
    debug "TE(notifyAll): on lock *#{_this.ref}"
    if (locker = rs.lock_refs[_this])?
      if locker isnt rs.curr_thread
        owner = thread_name rs, locker
        exceptions.java_throw rs, 'java/lang/IllegalMonitorStateException', "Thread '#{owner}' owns this monitor"
    if rs.waiting_threads[_this]?
      rs.waiting_threads[_this] = []
  'void wait(long timeout)': ->
    unless timeout is gLong.ZERO
      error "TODO(Object::wait): respect the timeout param (#{timeout})"
    rs.wait _this

_class Package =
  'static String getSystemPackage0(String jvm_str)': -> null

_class ProcessEnvironment =
  'static byte[][] environ()': ->
    env_arr = []
    # convert to an array of strings of the form [key, value, key, value ...]
    for k, v of process.env
      env_arr.push new JavaArray rs, c2t('[B'), util.bytestr_to_array k
      env_arr.push new JavaArray rs, c2t('[B'), util.bytestr_to_array v
    new JavaArray rs, c2t('[[B'), env_arr

_class Runtime =
  'int availableProcessors()': -> 1
  'void gc()': ->
    # No universal way of forcing browser to GC, so we yield in hopes
    # that the browser will use it as an opportunity to GC.
    rs.curr_frame().runner = -> rs.meta_stack().pop()
    throw new exceptions.YieldIOException (cb) -> setTimeout(cb, 0)

_class Shutdown =
  'static void halt0(int status)': -> throw new exceptions.HaltException(status)

_class StrictMath =
  'static double acos(double d_val)': -> Math.acos(d_val)
  'static double asin(double d_val)': -> Math.asin(d_val)
  'static double atan(double d_val)': -> Math.atan(d_val)
  'static double atan2(double y, double x)': -> Math.atan2(y, x)
  'static double cos(double d_val)': -> Math.cos(d_val)
  'static double exp(double d_val)': -> Math.exp(d_val)
  'static double log(double d_val)': -> Math.log(d_val)
  'static double pow(double base, double exp)': -> Math.pow(base,exp)
  'static double sin(double d_val)': -> Math.sin(d_val)
  'static double sqrt(double d_val)': -> Math.sqrt(d_val)
  'static double tan(double d_val)': -> Math.tan(d_val)
  # these two are native in OpenJDK but not Apple-Java
  'static double floor(double d_val)': -> Math.floor(d_val)
  'static double ceil(double d_val)': -> Math.ceil(d_val)

_class String =
  'String intern()': ->
    js_str = _this.jvm2js_str()
    unless (s = rs.string_pool.get(js_str))?
      s = rs.string_pool.set(js_str, _this)
    s

_import 'java.util.Properties'
_import 'java.io.InputStream'
_import 'java.io.PrintStream'

_class System =
  'static void arraycopy(Object src, int src_pos, Object dest, int dest_pos, int length)': ->
    # Needs to be checked *even if length is 0*.
    if !src? or !dest?
      exceptions.java_throw rs, 'java/lang/NullPointerException', 'Cannot copy to/from a null array.'
    # Can't do this on non-array types. Need to check before I check bounds below, or else I'll get an exception.
    if !(src.type instanceof types.ArrayType) or !(dest.type instanceof types.ArrayType)
      exceptions.java_throw rs, 'java/lang/ArrayStoreException', 'src and dest arguments must be of array type.'
    # Also needs to be checked *even if length is 0*.
    if src_pos < 0 or (src_pos+length) > src.array.length or dest_pos < 0 or (dest_pos+length) > dest.array.length or length < 0
      # System.arraycopy requires IndexOutOfBoundsException, but Java throws an array variant of the exception in practice.
      exceptions.java_throw rs, 'java/lang/ArrayIndexOutOfBoundsException', 'Tried to write to an illegal index in an array.'
    # Special case; need to copy the section of src that is being copied into a temporary array before actually doing the copy.
    if src == dest
      src = {type: src.type, array: src.array.slice(src_pos, src_pos+length)}
      src_pos = 0

    if types.is_castable rs, src.type, dest.type
      # Fast path
      arraycopy_no_check(src, src_pos, dest, dest_pos, length)
    else
      # Slow path
      # Absolutely cannot do this when two different primitive types, or a primitive type and a reference type.
      if (src.type.component_type instanceof types.PrimitiveType) or (dest.type.component_type instanceof types.PrimitiveType)
        exceptions.java_throw rs, 'java/lang/ArrayStoreException', 'If calling arraycopy with a primitive array, both src and dest must be of the same primitive type.'
      else
        # Must be two reference types.
        arraycopy_check(rs, src, src_pos, dest, dest_pos, length)
  'static long currentTimeMillis()': -> gLong.fromNumber((new Date).getTime())
  'static int identityHashCode(Object x)': -> x?.ref ? 0
  'static Properties initProperties(Properties props)': -> rs.push null # return value should not be used
  'static long nanoTime()': ->
    # we don't actually have nanosecond precision
    gLong.fromNumber((new Date).getTime()).multiply(gLong.fromNumber(1000000))
  'static void setIn0(InputStream stream)': ->
    rs.push stream
    rs.static_put {class:'java/lang/System', name:'in'}
  'static void setOut0(PrintStream stream)': ->
    rs.push stream
    rs.static_put {class:'java/lang/System', name:'out'}
  'static void setErr0(PrintStream stream)': ->
    rs.push stream
    rs.static_put {class:'java/lang/System', name:'err'}
  'static nonnative void loadLibrary(String jvm_str)': -> # NOP, because we don't support loading external libraries
  'static nonnative void adjustPropertiesForBackwardCompatibility(Properties props)': -> # NOP (apple-java specific)
  'static nonnative String getProperty(String jvm_key)': get_property
  'static nonnative String getProperty(String jvm_key, String _default)': get_property

get_property = (rs, jvm_key, _default = null) ->
  key = jvm_key.jvm2js_str()
  # XXX: mega hack, please make this better
  if key == 'java.class.path'
    # jvm is already defined in release mode
    classpath = jvm?.classpath ? require('./jvm').classpath
    # the last path is actually the bootclasspath (vendor/classes/)
    return rs.init_string classpath[0...classpath.length-1].join ':'
  val = system_properties[key]
  if val? then rs.init_string(val, true) else _default

# "Fast" array copy; does not have to check every element for illegal
# assignments. You can do tricks here (if possible) to copy chunks of the array
# at a time rather than element-by-element.
# This function *cannot* access any attribute other than 'array' on src due to
# the special case when src == dest (see code for System.arraycopy below).
arraycopy_no_check = (src, src_pos, dest, dest_pos, length) ->
  j = dest_pos
  for i in [src_pos...src_pos+length] by 1
    dest.array[j++] = src.array[i]
  # CoffeeScript, we are not returning an array.
  return

# "Slow" array copy; has to check every element for illegal assignments.
# You cannot do any tricks here; you must copy element by element until you
# have either copied everything, or encountered an element that cannot be
# assigned (which causes an exception).
# Guarantees: src and dest are two different reference types. They cannot be
#             primitive arrays.
arraycopy_check = (rs, src, src_pos, dest, dest_pos, length) ->
  j = dest_pos
  for i in [src_pos...src_pos+length] by 1
    # Check if null or castable.
    if src.array[i] == null or types.is_castable rs, src.array[i].type, dest.type.component_type
      dest.array[j] = src.array[i]
    else
      exceptions.java_throw rs, 'java/lang/ArrayStoreException', 'Array element in src cannot be cast to dest array type.'
    j++
  # CoffeeScript, we are not returning an array.
  return

_class Terminator =
  'static nonnative void setup()': -> # NOP, because we don't support threads

_class Thread =
  'static Thread currentThread()': -> rs.curr_thread
  'void setPriority0(int priority)': -> # NOP
  'static boolean holdsLock(Object obj)': -> rs.curr_thread is rs.lock_refs[obj]
  'boolean isAlive()': -> _this.$isAlive ? false
  'boolean isInterrupted(boolean clear_flag)': ->
    tmp = _this.$isInterrupted ? false
    _this.$isInterrupted = false if clear_flag
    tmp
  'void interrupt0()': ->
    _this.$isInterrupted = true
    debug "TE(interrupt0): interrupting #{thread_name rs, _this}"
    new_thread_sf = util.last _this.$meta_stack._cs
    new_thread_sf.runner = ->
      new_thread_sf.method.run_manually (->
        exceptions.java_throw rs, 'java/lang/InterruptedException', 'interrupt0 called'
      ), rs, []
    _this.$meta_stack.push {}  # dummy
    rs.yield _this
  'void start0()': ->
    _this.$isAlive = true
    _this.$meta_stack = new runtime.CallStack()
    rs.thread_pool.push _this
    old_thread_sf = rs.curr_frame()
    debug "TE(start0): starting #{thread_name rs, _this} from #{thread_name rs, rs.curr_thread}"
    rs.curr_thread = _this
    new_thread_sf = rs.curr_frame()
    rs.push _this
    run_method = rs.method_lookup({class: _this.type.toClassString(), sig: 'run()V'})
    thread_runner_sf = run_method.setup_stack(rs)
    new_thread_sf.runner = ->
      new_thread_sf.runner = null  # new_thread_sf is the fake SF at index 0
      _this.$isAlive = false
      debug "TE(start0): thread died: #{thread_name rs, _this}"
    old_thread_sf.runner = ->
      debug "TE(start0): thread resumed: #{thread_name rs, rs.curr_thread}"
      rs.meta_stack().pop()
    throw exceptions.ReturnException
  'static void sleep(long millis)': ->
    rs.curr_frame().runner = -> rs.meta_stack().pop()
    throw new exceptions.YieldIOException (cb) ->
      setTimeout(cb, millis.toNumber())
  'static void yield()': -> rs.yield()

_class Throwable =
  'nonnative Throwable fillInStackTrace()': ->
    stack = []
    strace = rs.init_array "[Ljava/lang/StackTraceElement;", stack
    _this.set_field rs, 'java/lang/Throwable/stackTrace', strace
    # we don't want to include the stack frames that were created by
    # the construction of this exception
    cstack = rs.meta_stack()._cs.slice(1,-1)
    for sf in cstack when sf.locals[0] isnt _this
      cls = sf.method.class_type
      unless _this.type.toClassString() is 'java/lang/NoClassDefFoundError'
        attrs = rs.load_class(cls).attrs
        source_file =
          _.find(attrs, (attr) -> attr.constructor.name == 'SourceFile')?.name or 'unknown'
      else
        source_file = 'unknown'
      line_nums = sf.method.code?.attrs?[0]?.entries
      if line_nums?
        # XXX: WUT
        ln = util.last(row.line_number for i,row of line_nums when row.start_pc <= sf.pc)
      ln ?= -1
      stack.push rs.init_object "java/lang/StackTraceElement", {
        'java/lang/StackTraceElement/declaringClass': rs.init_string util.ext_classname cls.toClassString()
        'java/lang/StackTraceElement/methodName': rs.init_string sf.method.name
        'java/lang/StackTraceElement/fileName': rs.init_string source_file
        'java/lang/StackTraceElement/lineNumber': ln
      }
    stack.reverse()
    _this
