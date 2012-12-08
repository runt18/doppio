_package 'sun.management'

_class VMManagementImpl =
  'long getStartupTime()': -> rs.startup_time
  'static String getVersion0()': -> rs.init_string "1.2", true
  'static void initOptionalSupportFields()': ->
    # set everything to false
    field_names = [ 'compTimeMonitoringSupport', 'threadContentionMonitoringSupport',
      'currentThreadCpuTimeSupport', 'otherThreadCpuTimeSupport',
      'bootClassPathSupport', 'objectMonitorUsageSupport', 'synchronizerUsageSupport' ]
    for name in field_names
      rs.push 0
      rs.static_put
        class: 'sun/management/VMManagementImpl'
        name: name
  'boolean isThreadAllocatedMemoryEnabled()': -> false
  'boolean isThreadContentionMonitoringEnabled()': -> false
  'boolean isThreadCpuTimeEnabled()': -> false
  'int getAvailableProcessors()': -> 1
  'int getProcessId()': -> 1

_import 'java.lang.management.MemoryManagerMXBean'
_import 'java.lang.management.MemoryPoolMXBean'

_class MemoryImpl =
  'static MemoryManagerMXBean[] getMemoryManagers0()': ->
    rs.init_array '[Lsun/management/MemoryManagerImpl;', [] # XXX may want to revisit this 'NOP'
  'static MemoryPoolMXBean[] getMemoryPools0()': ->
    rs.init_array '[Lsun/management/MemoryPoolImpl;', [] # XXX may want to revisit this 'NOP'
