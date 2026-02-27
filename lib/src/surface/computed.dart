part of 'surface.dart';

abstract class Computed<T> {
  T call();
  T get state;
  T get value;
}

final class _ComputedImpl<T> extends ComputedNode<T> implements Computed<T> {
  _ComputedImpl({required super.flags, required super.compute});

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T call() => get();

  @override
  T get state => get();

  @override
  T get value => get();
}

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
Computed<T> computed<T>(T Function() compute) {
  return _ComputedImpl(
    compute: compute,
    flags: ReactiveFlags.none,
  );
}
