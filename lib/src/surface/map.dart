part of 'surface.dart';

/// A reactive map whose mutations are observable.
///
/// The map itself implements [Map<K,V>] and also behaves as a [Signal]
/// containing the current map value.  Reading it inside a computed or effect
/// will register a dependency, and writing via either regular map methods or
/// the signal setter (`map.value = {...}`) triggers propagation.
abstract class MapSignal<K, V> implements Map<K, V>, Signal<Map<K, V>> {}

final class _MapSignalImpl<K, V> extends SignalNode<Map<K, V>>
    implements MapSignal<K, V> {
  _MapSignalImpl({
    required super.flags,
    required super.currentValue,
    required super.pendingValue,
  });

  Map<K, V> get _map => get();

  // Signal interface -----------------------------------------------------
  @override
  Map<K, V> call([Map<K, V>? value]) {
    if (value != null) set(value);
    return get();
  }

  @override
  Map<K, V> get value => get();

  @override
  set value(Map<K, V> v) => set(v);

  @override
  Map<K, V> get state => get();

  @override
  set state(Map<K, V> v) => set(v);

  @override
  Map<K, V> peek() => super.peek();

  void _replace(Map<K, V> newMap) {
    if (identical(newMap, _map)) return;
    set(newMap);
  }

  Map<K, V> _clone() => Map<K, V>.from(_map);

  // =========================
  // Core Overrides
  // =========================

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) {
    final current = _map;
    if (current[key] == value && current.containsKey(key)) return;

    final newMap = _clone()..[key] = value;
    _replace(newMap);
  }

  @override
  void addAll(Map<K, V> other) {
    if (other.isEmpty) return;

    final newMap = _clone()..addAll(other);
    _replace(newMap);
  }

  @override
  V? remove(Object? key) {
    if (!_map.containsKey(key)) return null;

    final newMap = _clone();
    final removed = newMap.remove(key);
    _replace(newMap);
    return removed;
  }

  @override
  void clear() {
    if (_map.isEmpty) return;
    _replace(<K, V>{});
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    final newMap = _clone()..removeWhere(test);
    if (newMap.length != _map.length) {
      _replace(newMap);
    }
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    final newMap = _clone()..updateAll(update);
    _replace(newMap);
  }

  @override
  V update(
    K key,
    V Function(V value) update, {
    V Function()? ifAbsent,
  }) {
    final newMap = _clone();
    final result = newMap.update(key, update, ifAbsent: ifAbsent);
    _replace(newMap);
    return result;
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    if (_map.containsKey(key)) return _map[key] as V;

    final newMap = _clone();
    final result = newMap.putIfAbsent(key, ifAbsent);
    _replace(newMap);
    return result;
  }

  // =========================
  // Read-only Delegations
  // =========================

  @override
  Iterable<K> get keys => _map.keys;

  @override
  Iterable<V> get values => _map.values;

  @override
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  @override
  int get length => _map.length;

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  bool containsKey(Object? key) => _map.containsKey(key);

  @override
  bool containsValue(Object? value) => _map.containsValue(value);

  @override
  void forEach(void Function(K key, V value) action) {
    _map.forEach(action);
  }

  @override
  Map<RK, RV> cast<RK, RV>() => _map.cast<RK, RV>();

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(K key, V value) transform,
  ) {
    return _map.map(transform);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    if (entries.isEmpty) return;

    final newMap = _clone()..addEntries(entries);
    _replace(newMap);
  }

  @override
  String toString() => _map.toString();
}

MapSignal<K, V> mapSignal<K, V>([
  Map<K, V> initialValue = const {},
]) {
  final cloned = Map<K, V>.from(initialValue);

  return _MapSignalImpl<K, V>(
    flags: ReactiveFlags.mutable,
    currentValue: cloned,
    pendingValue: cloned,
  );
}
