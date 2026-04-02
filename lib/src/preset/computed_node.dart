import 'reactive_flags.dart';
import 'reactive_node.dart';
import 'system.dart';

class ComputedNode<T> extends ReactiveNode {
  final T Function() compute;
  T? currentValue;
  ComputedNode({required super.flags, required this.compute});
  T get() {
    final flags = this.flags;
    if ((flags & ReactiveFlags.dirty) != ReactiveFlags.none ||
        ((flags & ReactiveFlags.pending) != ReactiveFlags.none &&
            (checkDirty(deps!, this) ||
                identical(
                  this.flags = flags & -33 /*~ReactiveFlags.pending*/,
                  false,
                )))) {
      if (didUpdate()) {
        final subs = this.subs;
        if (subs != null) {
          shallowPropagate(subs);
        }
      }
    } else if (flags == ReactiveFlags.none) {
      this.flags =
          5 /*ReactiveFlags.mutable | ReactiveFlags.recursedCheck*/
              as ReactiveFlags;
      final prevSub = setActiveSub(this);
      try {
        currentValue = compute();
      } finally {
        activeSub = prevSub;
        this.flags &= -5 /*~ReactiveFlags.recursedCheck*/;
      }
    }

    final sub = activeSub;
    if (sub != null) link(this, sub, cycle);

    return currentValue as T;
  }

  /// Like [get] but skips tracking the active subscriber.
  ///
  /// The computed value will still be updated if it is dirty or pending, but
  /// reading it does not create a dependency. This is useful when you just
  /// need the current result without causing the caller to re‑run when the
  /// computed value changes.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  T peek() {
    final flags = this.flags;
    if ((flags & ReactiveFlags.dirty) != ReactiveFlags.none ||
        ((flags & ReactiveFlags.pending) != ReactiveFlags.none &&
            (checkDirty(deps!, this) ||
                identical(
                  this.flags = flags & -33 /*~ReactiveFlags.pending*/,
                  false,
                )))) {
      if (didUpdate()) {
        final subs = this.subs;
        if (subs != null) {
          shallowPropagate(subs);
        }
      }
    } else if (flags == ReactiveFlags.none) {
      this.flags =
          5 /*ReactiveFlags.mutable | ReactiveFlags.recursedCheck*/
              as ReactiveFlags;
      final prevSub = setActiveSub(this);
      try {
        currentValue = compute();
      } finally {
        activeSub = prevSub;
        this.flags &= -5 /*~ReactiveFlags.recursedCheck*/;
      }
    }

    return currentValue as T;
  }

  bool didUpdate() {
    ++cycle;
    depsTail = null;
    flags = ReactiveFlags.mutable | ReactiveFlags.recursedCheck;
    final prevSub = setActiveSub(this);
    try {
      return !identical(currentValue, currentValue = compute());
    } finally {
      activeSub = prevSub;
      flags &= -5 /*~ReactiveFlags.recursedCheck*/;
      purgeDeps(this);
    }
  }
}
