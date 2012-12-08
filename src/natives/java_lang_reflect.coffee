_package 'java.lang.reflect'

_class Array =
  'static Object newArray(Class cls, int len)': ->
    rs.heap_newarray cls.$type, len
  'static int getLength(Object arr)': ->
    rs.check_null(arr).array.length

_class Proxy =
  'static Class defineClass0(ClassLoader cl, String name, byte[] bytes, int offset, int len)': ->
    native_define_class rs, name, bytes, offset, len, cl
