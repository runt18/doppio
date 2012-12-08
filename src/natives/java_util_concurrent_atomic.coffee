_package 'java.util.concurrent.atomic'

_class AtomicLong =
  'static boolean VMSupportsCS8()': -> true

_class AtomicInteger =
  'nonnative static void <clinit>()': -> #NOP
  'nonnative boolean compareAndSet(int expect: int update)': ->
    _this.set_field rs, 'java/util/concurrent/atomic/AtomicInteger/value', update  # we don't need to compare, just set
    true # always true, because we only have one thread
