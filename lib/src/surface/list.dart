part of 'surface.dart';

/// A reactive list whose mutations are observable.
///
/// See [MapSignal] for details about the dual `List`/`Signal` behavior.
abstract class ListSignal<E> implements List<E>, Signal<List<E>> {}

final class _ListSignalImpl<E> extends SignalNode<List<E>>
    with ListMixin<E>
    implements ListSignal<E> {
  _ListSignalImpl({
    required super.flags,
    required super.currentValue,
    required super.pendingValue,
  });

  List<E> get _list => get();

  // Signal interface -----------------------------------------------------
  @override
  List<E> call([List<E>? value]) {
    if (value != null) set(value);
    return get();
  }

  @override
  List<E> get value => get();

  @override
  set value(List<E> v) => set(v);

  @override
  List<E> get state => get();

  @override
  set state(List<E> v) => set(v);

  @override
  List<E> peek() => super.peek();

  List<E> _clone() => List<E>.from(_list);

  void _replace(List<E> newList) {
    if (identical(newList, _list)) return;
    set(newList);
  }

  // =========================
  // Required by ListMixin
  // =========================

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    if (newLength == _list.length) return;

    final newList = _clone()..length = newLength;
    _replace(newList);
  }

  @override
  E operator [](int index) => _list[index];

  @override
  void operator []=(int index, E value) {
    if (_list[index] == value) return;

    final newList = _clone()..[index] = value;
    _replace(newList);
  }

  // =========================
  // Override Mutators for Reactivity
  // =========================

  @override
  void add(E value) {
    final newList = _clone()..add(value);
    _replace(newList);
  }

  @override
  void addAll(Iterable<E> iterable) {
    if (iterable.isEmpty) return;

    final newList = _clone()..addAll(iterable);
    _replace(newList);
  }

  @override
  void insert(int index, E element) {
    final newList = _clone()..insert(index, element);
    _replace(newList);
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    if (iterable.isEmpty) return;

    final newList = _clone()..insertAll(index, iterable);
    _replace(newList);
  }

  @override
  bool remove(Object? value) {
    if (!_list.contains(value)) return false;

    final newList = _clone();
    final removed = newList.remove(value);
    _replace(newList);
    return removed;
  }

  @override
  E removeAt(int index) {
    final newList = _clone();
    final removed = newList.removeAt(index);
    _replace(newList);
    return removed;
  }

  @override
  E removeLast() {
    final newList = _clone();
    final removed = newList.removeLast();
    _replace(newList);
    return removed;
  }

  @override
  void removeWhere(bool Function(E element) test) {
    final newList = _clone()..removeWhere(test);
    if (newList.length != _list.length) {
      _replace(newList);
    }
  }

  @override
  void retainWhere(bool Function(E element) test) {
    final newList = _clone()..retainWhere(test);
    if (newList.length != _list.length) {
      _replace(newList);
    }
  }

  @override
  void clear() {
    if (_list.isEmpty) return;
    _replace(<E>[]);
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    final newList = _clone()..setAll(index, iterable);
    _replace(newList);
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    final newList = _clone()..sort(compare);
    _replace(newList);
  }

  @override
  void shuffle([Random? random]) {
    final newList = _clone()..shuffle(random);
    _replace(newList);
  }
}

ListSignal<E> listSignal<E>([
  List<E> initial = const [],
]) {
  final cloned = List<E>.from(initial);

  return _ListSignalImpl<E>(
    flags: ReactiveFlags.mutable,
    currentValue: cloned,
    pendingValue: cloned,
  );
}
