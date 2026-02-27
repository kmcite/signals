import 'link.dart';
import 'reactive_flags.dart';
import 'reactive_node.dart';
import 'system.dart';

class SignalNode<T> extends ReactiveNode {
  T currentValue;
  T pendingValue;

  SignalNode({
    required super.flags,
    required this.currentValue,
    required this.pendingValue,
  });

  void set(T newValue) {
    if (!identical(pendingValue, newValue)) {
      pendingValue = newValue;
      flags =
          17 /*ReactiveFlags.mutable | ReactiveFlags.dirty*/ as ReactiveFlags;
      if (subs case final Link subs) {
        propagate(subs);
        if (batchDepth == 0) flush();
      }
    }
  }

  @pragma('vm:align-loops')
  T get() {
    if ((flags & ReactiveFlags.dirty) != ReactiveFlags.none) {
      if (didUpdate()) {
        final subs = this.subs;
        if (subs != null) {
          shallowPropagate(subs);
        }
      }
    }
    ReactiveNode? sub = activeSub;
    while (sub != null) {
      if ((sub.flags &
              3 /*(ReactiveFlags.mutable | ReactiveFlags.watching)*/ ) !=
          ReactiveFlags.none) {
        link(this, sub, cycle);
        break;
      }
      sub = sub.subs?.sub;
    }
    return currentValue;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  bool didUpdate() {
    flags = ReactiveFlags.mutable;
    return !identical(currentValue, currentValue = pendingValue);
  }
}
