_package 'sun.misc'

_class VM =
  'static void initialize()': ->
    vm_cls = rs.class_lookup c2t 'sun/misc/VM'
    # this only applies to Java 7
    return unless vm_cls.major_version >= 51
    # hack! make savedProps refer to the system props
    rs.push rs.static_get {class:'java/lang/System',name:'props'}
    rs.static_put {class:'sun/misc/VM',name:'savedProps'}

_import 'java.lang.reflect.Field'
_import 'java.security.ProtectionDomain'

_class Unsafe =
  'int addressSize()': -> 4 # either 4 or 8
  'Object allocateInstance(Class cls)': ->
    rs.init_object cls.$type.toClassString(), {}
  'long allocateMemory(long size)': ->
    next_addr = util.last(rs.mem_start_addrs)
    rs.mem_blocks[next_addr] = new DataView new ArrayBuffer size
    rs.mem_start_addrs.push next_addr + size
    gLong.fromNumber next_addr
  'void setMemory(long address, long bytes, byte value)': ->
    block_addr = rs.block_addr(address)
    for i in [0...bytes] by 1
      rs.mem_blocks[block_addr].setInt8(i, value)
  'void freeMemory(long address)': ->
    delete rs.mem_blocks[address.toNumber()]
    rs.mem_start_addrs.splice(rs.mem_start_addrs.indexOf(address), 1)
  'void putLong(long address, long value)': ->
    block_addr = rs.block_addr(address)
    offset = address - block_addr
    # little endian
    rs.mem_blocks[block_addr].setInt32(offset, value.getLowBits(), true)
    rs.mem_blocks[block_addr].setInt32(offset + 4, value.getHighBits, true)
  'byte getByte(long address)': ->
    block_addr = rs.block_addr(address)
    rs.mem_blocks[block_addr].getInt8(address - block_addr)
  'int arrayBaseOffset(Class cls)': -> 0
  'int arrayIndexScale(Class cls)': -> 1
  'boolean compareAndSwapObject(Object obj, long offset, Object expected, Object x)': unsafe_compare_and_swap
  'boolean compareAndSwapInt(Object obj, long offset, int expected, int x)': unsafe_compare_and_swap
  'boolean compareAndSwapLong(Object obj, long offset, long expected, long x)Z': unsafe_compare_and_swap
  'void ensureClassInitialized(Class cls)': ->
    rs.class_lookup(cls.$type)
  'long staticFieldOffset(Field field)': -> gLong.fromNumber(field.get_field rs, 'java/lang/reflect/Field/slot')
  'long objectFieldOffset(Field field)': -> gLong.fromNumber(field.get_field rs, 'java/lang/reflect/Field/slot')
  'Object staticFieldBase(Field field)': ->
    cls = field.get_field rs, 'java/lang/reflect/Field/clazz'
    new JavaObject rs, cls.$type, rs.class_lookup(cls.$type)
  'Object getObjectVolatile(Object obj, long offset)': ->
    obj.get_field_from_offset rs, offset
  'Object getObject(Object obj, long offset)': ->
    obj.get_field_from_offset rs, offset
  'void putObject(Object obj, long offset, Object new_obj)': ->
    obj.set_field_from_offset rs, offset, new_obj
  'void putOrderedObject(Object obj, long offset, Object new_obj)': ->
    obj.set_field_from_offset rs, offset, new_obj
  'Class defineClass(String name, byte[] bytes, int offset, int len, ClassLoader loader, ProtectionDomain pd)': ->
    native_define_class rs, name, bytes, offset, len, loader

unsafe_compare_and_swap = (rs, _this, obj, offset, expected, x) ->
  actual = obj.get_field_from_offset rs, offset
  if actual == expected
    obj.set_field_from_offset rs, offset, x
    true
  else
    false
