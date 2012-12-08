_package 'java.util'

_class ResourceBundle =
  'static Class[] getClassContext()': ->
    # XXX should walk up the meta_stack and fill in the array properly
    rs.init_array '[Ljava/lang/Class;', [null,null,null]

_class TimeZone =
  'static String getSystemTimeZoneID(String java_home, String country)': ->
    rs.init_string 'GMT' # XXX not sure what the local value is
  'static String getSystemGMTOffsetID()': ->
    null # XXX may not be correct

_class Currency =
  'static nonnative Currency getInstance(String jvm_str)': -> null # because it uses lots of reflection and we don't need it
