part of 'surface.dart';

/// A reactive signal backed by a [Stream].
///
/// The signal's value is updated each time the stream emits.  It behaves like
/// any other [Signal<T>] (you can read via `.value`, `.call()`, or
/// `.peek()`) and you may optionally assign to it manually.  Call [dispose]
/// when you no longer need updates to cancel the underlying subscription.
abstract class StreamSignal<T> implements Signal<T> {
  /// Read current value
  @override
  T call([T? value]);

  /// Alias for call()
  @override
  T get value;

  /// Alias for call()
  @override
  T get state;

  /// Dispose the internal stream subscription
  void dispose();

  /// Read the current value without registering a dependency.
  @override
  T peek();
}

final class _StreamSignalImpl<T> extends SignalNode<T>
    implements StreamSignal<T> {
  _StreamSignalImpl({
    required super.flags,
    required super.currentValue,
    required super.pendingValue,
    required Stream<T> stream,
  }) {
    _subscription = stream.listen((v) => set(v));
  }

  StreamSubscription<T>? _subscription;

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T call([T? value]) {
    if (value != null) set(value);
    return get();
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T get value => get();

  @override
  set value(T v) => set(v);

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T get state => get();

  @override
  set state(T v) => set(v);

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T peek() => super.peek();

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
StreamSignal<T> streamSignal<T>(
  Stream<T> stream, {
  required T initialValue,
}) {
  return _StreamSignalImpl(
    flags: ReactiveFlags.mutable,
    currentValue: initialValue,
    pendingValue: initialValue,
    stream: stream,
  );
}
