_package 'java.security'

_class AccessController =
  'static Object doPrivileged(PrivilegedAction action)': doPrivileged
  'static Object doPrivileged(PrivilegedAction action, AccessControlContext context)': doPrivileged
  'static Object doPrivileged(PrivilegedExceptionAction action)': doPrivileged
  'static Object doPrivileged(PrivilegedExceptionAction action, AccessControlContext context)': doPrivileged
  'static AccessControlContext getStackAccessControlContext()': -> null

doPrivileged = (rs, action) ->
  my_sf = rs.curr_frame()
  m = rs.method_lookup(class: action.type.toClassString(), sig: 'run()Ljava/lang/Object;')
  rs.push action unless m.access_flags.static
  m.setup_stack(rs)
  my_sf.runner = ->
    rv = rs.pop()
    rs.meta_stack().pop()
    rs.push rv
  throw exceptions.ReturnException
