part of 'surface.dart';
// parameterized_computed.dart

// ─────────────────────────────────────────────
// Cache Policies
// ─────────────────────────────────────────────

enum CacheEvictionPolicy {
  /// Keep all entries forever (until manual dispose). Good for small fixed sets.
  unlimited,

  /// Least-Recently-Used eviction when [maxSize] is exceeded.
  lru,

  /// Entries are removed once they have no active watchers.
  /// (Requires alien_signals subscriber tracking — use with Watch widgets.)
  autoDispose,
}

// ─────────────────────────────────────────────
// Entry — internal
// ─────────────────────────────────────────────

class _Entry<P, T> {
  _Entry({
    required this.paramSignal,
    required this.computed,
    required this.key,
  });

  final P key; // original cache key
  final Signal<P> paramSignal;
  final Computed<T> computed;
  // ignore: unused_field
  int _lastUsed = DateTime.now().millisecondsSinceEpoch;

  void touch() => _lastUsed = DateTime.now().millisecondsSinceEpoch;
}

// ─────────────────────────────────────────────
// Result handle returned to caller
// ─────────────────────────────────────────────

class ParamComputedHandle<P, T> {
  const ParamComputedHandle._({
    required this.computed,
    required void Function(P) updater,
    required void Function() disposer,
  }) : _updater = updater,
       _disposer = disposer;

  /// The reactive computed. Use `.value` inside Watch/effect.
  final Computed<T> computed;

  final void Function(P) _updater;
  final void Function() _disposer;

  /// Update the underlying param signal, causing [computed] to recompute.
  void updateParam(P newParam) => _updater(newParam);

  /// Remove this entry from the cache and release resources.
  void dispose() => _disposer();

  /// Convenience: current value (non-reactive read).
  T get value => computed.value;
}

// ─────────────────────────────────────────────
// Core API
// ─────────────────────────────────────────────

class ParameterizedComputed<P, T> {
  ParameterizedComputed({
    required this.factory,
    this.policy = CacheEvictionPolicy.lru,
    this.maxSize = 50,
    this.equals,
    this.debugLabel,
  }) : _cache = LinkedHashMap(
         equals: equals?.$1,
         hashCode: equals?.$2,
       );

  /// Factory that builds the computed value from a param signal.
  /// Receives the param signal so the computed is fully reactive to param changes.
  final Computed<T> Function(Signal<P> paramSignal) factory;

  final CacheEvictionPolicy policy;
  final int maxSize;

  /// Optional custom equality for cache keys: (equals, hashCode) tuple.
  final ({bool Function(P, P) $1, int Function(P) $2})? equals;

  final String? debugLabel;

  final LinkedHashMap<P, _Entry<P, T>> _cache;

  bool get isEmpty => _cache.isEmpty;
  int get size => _cache.length;

  // ── Main API ──────────────────────────────

  /// Get or create a parameterized computed for [param].
  /// Returns a [ParamComputedHandle] with the computed and control methods.
  ParamComputedHandle<P, T> call(P param) => _getOrCreate(param);

  /// Explicit named alias for [call].
  ParamComputedHandle<P, T> get(P param) => _getOrCreate(param);

  /// Returns true if an entry for [param] is currently cached.
  bool isCached(P param) => _cache.containsKey(param);

  /// Manually evict a specific param from the cache.
  void evict(P param) => _cache.remove(param);

  /// Evict all entries.
  void clear() => _cache.clear();

  /// Dispose everything — call in your ViewModel/controller dispose().
  void dispose() => clear();

  // ── Internals ─────────────────────────────

  ParamComputedHandle<P, T> _getOrCreate(P param) {
    final existing = _cache[param];

    if (existing != null) {
      existing.touch();

      if (policy == CacheEvictionPolicy.lru) {
        // Re-insert to mark as recently used (LinkedHashMap preserves order)
        _cache.remove(param);
        _cache[param] = existing;
      }

      return _handle(existing);
    }

    // Evict if needed before inserting
    if (policy == CacheEvictionPolicy.lru && _cache.length >= maxSize) {
      _evictLruEntry();
    }

    final paramSignal = signal<P>(param);
    final comp = factory(paramSignal);

    final entry = _Entry<P, T>(
      key: param,
      paramSignal: paramSignal,
      computed: comp,
    );

    _cache[param] = entry;

    return _handle(entry);
  }

  ParamComputedHandle<P, T> _handle(_Entry<P, T> entry) {
    return ParamComputedHandle._(
      computed: entry.computed,
      updater: (newParam) {
        entry.paramSignal.value = newParam;
        entry.touch();
      },
      disposer: () => evict(entry.key),
    );
  }

  void _evictLruEntry() {
    // LinkedHashMap iteration is insertion order; first = least recently used
    if (_cache.isNotEmpty) {
      _cache.remove(_cache.keys.first);
    }
  }
}

// ─────────────────────────────────────────────
// Convenience constructors / factory helpers
// ─────────────────────────────────────────────

/// Shorthand for creating a [ParameterizedComputed] with a simple value factory.
/// [builder] receives the raw param value (not the signal) for convenience.
/// The computed is still fully reactive to param changes via the signal internally.
ParameterizedComputed<P, T> paramComputed<P, T>({
  required T Function(P param) builder,
  CacheEvictionPolicy policy = CacheEvictionPolicy.lru,
  int maxSize = 50,
  ({bool Function(P, P) $1, int Function(P) $2})? equals,
  String? debugLabel,
}) {
  return ParameterizedComputed<P, T>(
    factory: (paramSignal) => computed(() => builder(paramSignal.value)),
    policy: policy,
    maxSize: maxSize,
    equals: equals,
    debugLabel: debugLabel,
  );
}

/// For cases where the builder needs access to the raw param signal
/// (e.g. to combine with other signals inside the computed).
ParameterizedComputed<P, T> paramComputedFromSignal<P, T>({
  required Computed<T> Function(Signal<P> paramSignal) factory,
  CacheEvictionPolicy policy = CacheEvictionPolicy.lru,
  int maxSize = 50,
  ({bool Function(P, P) $1, int Function(P) $2})? equals,
  String? debugLabel,
}) {
  return ParameterizedComputed<P, T>(
    factory: factory,
    policy: policy,
    maxSize: maxSize,
    equals: equals,
    debugLabel: debugLabel,
  );
}
