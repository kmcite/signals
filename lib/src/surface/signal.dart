part of 'surface.dart';

abstract class Signal<T> {
  T call([T? value]);
  set state(T value);
  set value(T value);
  T get state;
  T get value;

  /// Read the current value without tracking a dependency.
  T peek();
}

final class _SignalImpl<T> extends SignalNode<T> implements Signal<T> {
  _SignalImpl({
    required super.flags,
    required super.currentValue,
    required super.pendingValue,
  });

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T call([T? value]) {
    if (value != null) set(value);
    return get();
  }

  @override
  get value => get();
  @override
  set value(T value) => set(value);

  @override
  get state => get();
  @override
  set state(T value) => set(value);

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T peek() => super.peek();
}

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
Signal<T> signal<T>(T initialValue) {
  return _SignalImpl(
    flags: ReactiveFlags.mutable,
    currentValue: initialValue,
    pendingValue: initialValue,
  );
}
