_package 'sun.reflect'

_import 'java.lang.reflect.Method'
_import 'java.lang.reflect.Constructor'

_class ConstantPool =
  'long getLongAt0(Object cp, int idx)': ->
    cp.get(idx).value
  'String getUTF8At0(Object cp, int idx)': ->
    rs.init_string cp.get(idx).value

_class NativeMethodAccessorImpl =
  'static Object invoke0(Method m, Object obj, Object[] params)': ->
    cls = m.get_field rs, 'java/lang/reflect/Method/clazz'
    slot = m.get_field rs, 'java/lang/reflect/Method/slot'
    method = (method for sig, method of rs.class_lookup(cls.$type, true).methods when method.idx is slot)[0]
    my_sf = rs.curr_frame()
    rs.push obj unless method.access_flags.static
    rs.push_array params.array
    method.setup_stack(rs)
    my_sf.runner = ->
      rv = rs.pop()
      rs.meta_stack().pop()
      rs.push rv
    throw exceptions.ReturnException

_class NativeConstructorAccessorImpl =
  'static Object newInstance0(Constructor m, Object[] params)': ->
    cls = m.get_field rs, 'java/lang/reflect/Constructor/clazz'
    slot = m.get_field rs, 'java/lang/reflect/Constructor/slot'
    method = (method for sig, method of rs.class_lookup(cls.$type, true).methods when method.idx is slot)[0]
    my_sf = rs.curr_frame()
    rs.push (obj = new JavaObject rs, cls.$type, rs.class_lookup(cls.$type))
    rs.push_array params.array if params?
    method.setup_stack(rs)
    my_sf.runner = ->
      rs.meta_stack().pop()
      rs.push obj
    throw exceptions.ReturnException

_class Reflection =
  'static Class getCallerClass(int frames_to_skip)': ->
    #TODO: disregard frames assoc. with java.lang.reflect.Method.invoke() and its implementation
    caller = rs.meta_stack().get_caller(frames_to_skip)
    type = caller.method.class_type
    rs.jclass_obj(type, true)
  'static int getClassAccessFlags(Class class_obj)': ->
    class_obj.file.access_byte
