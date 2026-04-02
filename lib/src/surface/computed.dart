part of 'surface.dart';

abstract class Computed<T> {
  T call();
  T get state;
  T get value;

  /// Read the current computed value without registering the caller as a
  /// dependent.
  T peek();
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

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T peek() => super.peek();
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
