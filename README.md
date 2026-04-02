# signals

A minimal reactive state library built on top of Dart.  The code in this
workspace serves both as a demonstration of the underlying engine and as a
convenient toolkit for Flutter applications.

---

## Reactive system at a glance

The library implements a few core concepts:

* **Signal** – a writable, observable value (`Signal<T>`) backed by
  `SignalNode`.  Signals hold state and notify dependents when changed.
* **Computed** – a read‑only value derived from other signals/computeds.  It
  tracks dependencies automatically and recomputes when necessary.
* **Effect** – a callback that re‑runs whenever the signals it touches change.
* **Dependency tracking** – during a read, a global `activeSub` node is set;
  any signal/computed accessed while `activeSub` is non‑null links to it.
  Mutations propagate through a linked list of subscribers.

The engine lives in `lib/src/preset` (see `system.dart` for the details).
Public APIs are exposed via `lib/src/surface` and re‑exported from
`signals.dart`.

### Core helpers

```dart
// write a signal
final counter = signal(0);

// read the value (also tracks dependency)
print(counter());         // 0

// update and notify
counter(1);

// computed value
final doubleCount = computed(() => counter() * 2);
print(doubleCount());      // 2

// effect – runs once immediately and again whenever its dependencies change
final e = effect(() {
  print('counter is ${counter()}');
});

// stop the effect
e();
```

---

## Working with signals

### Declaration

```dart
Signal<int> value = signal(42);
```

Signals implement a small subset of the `Signal` interface:

- `value` / `state` – getters that read the current value.
- `value = …` / `state = …` – setters that update the value.
- `call([v])` – shorthand for getter/setter (function‑like syntax).
- `peek()` – read the value **without** tracking a dependency (see below).

**Note:** reading a signal inside a computed or effect automatically
registers the reader as a dependent.

### Peeking

```dart
int current = counter.peek(); // does not link the caller
```

This is handy in places where you want the value but you don't want the
containing computation/handler to re‑run when the signal changes.

### Batching mutations

Mutations normally trigger immediate propagation.  To coalesce multiple
writes into a single notification use `batch`:

```dart
batch(() {
  a(1);
  b(2);
  c(3);
});
// effects will run once after the block completes
```

Under the hood `batch` increments `batchDepth`; effects are flushed only
when the depth returns to zero.  You can also call `startBatch()`/
`endBatch()` directly if you prefer.

### Untracked evaluation

Sometimes you want to read a signal/computed but **not** establish a
dependency.  `untracked` does exactly that:

```dart
final foo = untracked(() => someSignal() + otherComputed());
```

`untracked` temporarily clears `activeSub` while the callback runs.
This is particularly useful when building caches or rendering debug output.

---

## Computed values

Computed values behave like lazy, memoized functions that automatically
track the signals they read.

```dart
final isEven = computed(() => counter() % 2 == 0);
print(isEven()); // true or false
```

Computed nodes recompute only when one of their dependencies changes.  You
can call `.peek()` on them as well to read the last computed result without
registering a new lookup.

Advanced note: a computed value marked dirty during propagation will still
recompute when read; the node keeps flags to manage pending vs dirty states.

---

## Effects and scopes

`effect(fn)` immediately invokes `fn` and reruns it whenever any signal or
computed read inside `fn` changes:

```dart
final dispose = effect(() {
  print('new count: ${counter()}');
});

// later …
dispose(); // stops the effect
```

For grouping effects without an immediate invocation use `effectScope`:

```dart
final scope = effectScope(() {
  effect(() => print('a: ${a()}'));
  effect(() => print('b: ${b()}'));
});

// teardown all contained effects:
scope();
```

---

## Reactive collections

Several convenient wrappers build signals over common Dart types.  The
`MapSignal`/`ListSignal` types now **implement `Signal<Map<K,V>>` and
`Signal<List<E>>` respectively**, meaning you can treat them like ordinary
signals as well as mutable collections:

```dart
final map = mapSignal<int, String>();
map[1] = 'one';          // map API
map.value = {'a':'b'};   // signal setter
print(map());            // read via call()
print(map.peek());       // read without tracking

final list = listSignal<String>(['a']);
list.add('b');
print(list.state);
```

Mutating methods produce a new copy of the underlying collection, then
update the signal, triggering notifications.

```dart
final streamSig = streamSignal(firehose, initialValue: 0);
```

## Async signals

The library includes helpers for listening to streams and futures reactively.
These types now integrate with the core API:

* `StreamSignal<T>` implements `Signal<T>`; you can `peek()` the current
  value, and even write to it manually if desired.  It still listens to the
  stream and updates itself on every event, and provides a `dispose()`
  method to cancel the subscription.
* `FutureSignal<T>` wraps a future and exposes a `Data<T>` state (loading,
  ok, error).  It offers `peek()` to read the state without tracking and
  `refresh()` to re‑execute the future.  It no longer implements `Signal`
  directly, but behaves like one via its standard getters/`call()`.

```dart
final streamSig = streamSignal<int>(socket, initialValue: 0);
final futureSig = futureSignal(() async => fetchUser(id));
```

The async signals participate in batching and untracked reads just like
ordinary signals.

---

## Parameterized computed values

Sometimes you want a computed value that depends on a parameter.  The
`ParameterizedComputed` helper caches results and supports eviction policies
(`unlimited`, `lru`, `autoDispose`).

```dart
final users = paramComputed<int, User>(
  builder: (id) => fetchUser(id),
  policy: CacheEvictionPolicy.lru,
  maxSize: 100,
);

final handle = users(42);
print(handle.computed());           // reactive read
handle.updateParam(43);             // change parameter
handle.dispose();                   // remove from cache
```

There are also `paramComputedFromSignal` and the generic
`ParameterizedComputed` constructor if you need the raw parameter signal.

---

## Flutter widget integration

Two helpers make it easy to build reactive user interfaces:

* `UI` – a base class extending `StatefulWidget` that reruns its `build`
  method whenever the signals it reads change.  See `lib/src/surface/ui.dart`.

Example from `example/main.dart`:

```dart
class CounterPage extends UI {
  @override
  Widget build(BuildContext context) {
    return Text('${count()}'); // automatically tracked
  }
}
```

There is also a second, more structured example in
`example/architecture_example.dart` which demonstrates a clean MVVM‑style
architecture.  Run it with:

```bash
flutter run -t example/architecture_example.dart
```

Under the hood, `UIState` uses an effect to re‑render when dependencies
change and schedules `setState` on the next microtask.

---

## Advanced topics

* **Manual control:** `startBatch`, `endBatch`, `trigger`, `flush`,
  `checkDirty`, etc. are available in `lib/src/preset/system.dart` if you
  need finer-grained control.
* **Debugging:** you can inspect `batchDepth`, `cycle`, and other globals to
  reason about propagation order.
* **Disposal:** `Effect` and `EffectScope` are stopped by calling them;
  `StreamSignal` and `FutureSignal` have explicit `dispose()` methods.
* **Thread safety:** the system is designed for single-threaded Dart
  contexts (UI isolates); there are no synchronous locks.

---

## Example application

The `example` directory contains a simple counter app demonstrating
`computed`, reactive collections, and the `UI` widget.  Run it with

```bash
flutter run -t example/main.dart
```

---

## Contributing & license

The code in this workspace is MIT‑licensed (see `LICENSE`).  Contributions are
welcome; please open issues or PRs against the repository.

---

This document should help you understand and use the reactive system.
Feel free to copy sections into your own projects or extend the library as
needed.
