import 'dart:async';

import 'package:flutter/widgets.dart';

import '../preset/computed_node.dart';
import '../preset/effect_node.dart';
import '../preset/system.dart';
import '../preset/signal_node.dart';
import '../preset/reactive_flags.dart';
import '../preset/reactive_node.dart';

part 'ui.dart';
part 'signal.dart';
part 'computed.dart';
part 'effect.dart';
part 'effect_scope.dart';

Signal<List<T>> listSignal<T>([List<T> initialValue = const []]) {
  return signal(initialValue);
}

Signal<Map<K, V>> mapSignal<K, V>([Map<K, V> initialValue = const {}]) {
  return signal(initialValue);
}

extension ListSignalExtensions<T> on Signal<List<T>> {
  void add(T item) {
    this([...this(), item]);
  }

  void remove(T item) {
    this(this().where((i) => i != item).toList());
  }
}

extension MapSignalExtensions<K, V> on Signal<Map<K, V>> {
  void put(K key, V item) {
    this({...this(), key: item});
  }

  void remove(K key) {
    this(Map.of(this())..remove(key));
  }
}
