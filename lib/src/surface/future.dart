part of 'surface.dart';

sealed class Data<T> {
  const Data();

  bool get isLoading => this is DataLoading<T>;
  bool get hasData => this is DataOk<T>;
  bool get hasError => this is DataError<T>;

  T? get value => this is DataOk<T> ? (this as DataOk<T>).value : null;

  Object? get error =>
      this is DataError<T> ? (this as DataError<T>).error : null;

  StackTrace? get stackTrace =>
      this is DataError<T> ? (this as DataError<T>).stackTrace : null;

  R when<R>({
    required R Function() loading,
    required R Function(T value) data,
    required R Function(Object error, StackTrace? stack) error,
  }) {
    final self = this;
    if (self is DataLoading<T>) return loading();
    if (self is DataOk<T>) return data(self.value);
    if (self is DataError<T>) {
      return error(self.error, self.stackTrace);
    }
    throw StateError('Unhandled Data state');
  }

  factory Data.loading() = DataLoading<T>;
  factory Data.ok(T value) = DataOk<T>;
  factory Data.error(Object error, [StackTrace? stackTrace]) = DataError<T>;
}

final class DataLoading<T> extends Data<T> {
  const DataLoading();
}

final class DataOk<T> extends Data<T> {
  final T value;
  const DataOk(this.value);
}

final class DataError<T> extends Data<T> {
  final Object error;
  final StackTrace? stackTrace;

  const DataError(this.error, [this.stackTrace]);
}

/// A reactive signal backed by a `Future<T>`.
///
/// The signal holds a [Data<T>] state representing loading / error / value
/// and updates itself as the future completes.  Use [refresh] to rerun the
/// future; call [dispose] to cancel further updates.  You can also peek at
/// the current state without tracking using [peek()].
abstract class FutureSignal<T> {
  /// Current state of the signal (Data.loading / Data.ok / Data.error)
  Data<T> get state;

  /// Read current state
  Data<T> call();

  /// Current value (null if loading or error)
  T? get value;

  /// Force recompute from the future
  Future<void> refresh();

  /// Dispose internal subscription / cleanup
  void dispose();

  /// Read without tracking
  Data<T> peek();
}

extension FutureSignalWhen<T> on FutureSignal<T> {
  /// Pattern-match the current state
  R when<R>({
    required R Function() loading,
    required R Function(T value) data,
    required R Function(Object error, StackTrace? stack) error,
  }) {
    final s = state;
    if (s.isLoading) {
      return loading();
    } else if (s.value != null) {
      return data(s.value as T);
    } else {
      return error(s.error!, s.stackTrace);
    }
  }
}

final class _FutureSignalImpl<T> extends SignalNode<Data<T>>
    implements FutureSignal<T> {
  _FutureSignalImpl({
    required super.flags,
    required super.currentValue,
    required super.pendingValue,
    required Future<T> Function() futureFn,
  }) : _futureFn = futureFn {
    _load();
  }

  final Future<T> Function() _futureFn;
  bool _disposed = false;

  /// Load / reload the future
  Future<void> _load() async {
    if (_disposed) return;

    // set loading state
    set(Data.loading());

    try {
      final result = await _futureFn();
      if (_disposed) return;
      set(Data.ok(result));
    } catch (e, st) {
      if (_disposed) return;
      set(Data.error(e, st));
    }
  }

  @override
  Data<T> get state => get();

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T? get value => state.value;

  @override
  Future<void> refresh() => _load();

  @override
  void dispose() {
    _disposed = true;
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  Data<T> call() => state;

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  Data<T> peek() => super.peek();
}

/// Create a future signal
@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
FutureSignal<T> futureSignal<T>(
  Future<T> Function() future, {
  Data<T>? initialState,
}) {
  final init = initialState ?? Data.loading();
  return _FutureSignalImpl(
    flags: ReactiveFlags.mutable,
    currentValue: init,
    pendingValue: init,
    futureFn: future,
  );
}
