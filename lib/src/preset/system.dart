import 'link.dart';
import 'reactive_flags.dart';
import 'reactive_node.dart';
import 'i_system.dart';
import 'computed_node.dart';
import 'effect_node.dart';
import 'linked_effect.dart';
import 'signal_node.dart';

int cycle = 0;

int batchDepth = 0;

ReactiveNode? activeSub;

LinkedEffect? queuedEffects;

LinkedEffect? queuedEffectsTail;

@pragma('vm:prefer-inline')
@pragma('wasm:prefer-inline')
const reactiveSystem = SystemImpl();

@pragma('vm:prefer-inline')
@pragma('wasm:prefer-inline')
final link = reactiveSystem.link,
    unlink = reactiveSystem.unlink,
    propagate = reactiveSystem.propagate,
    checkDirty = reactiveSystem.checkDirty,
    shallowPropagate = reactiveSystem.shallowPropagate;

class SystemImpl extends System {
  const SystemImpl();

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  bool update(ReactiveNode node) {
    return switch (node) {
      ComputedNode() => node.didUpdate(),
      SignalNode() => node.didUpdate(),
      _ => false,
    };
  }

  @override
  @pragma('vm:align-loops')
  void notify(ReactiveNode effect) {
    LinkedEffect? head;
    final LinkedEffect tail = effect as LinkedEffect;

    do {
      (effect as LinkedEffect).nextEffect = head;
      head = effect;
      effect.flags &= -3 /*~ReactiveFlags.watching*/;

      final next = effect.subs?.sub;
      if (next == null ||
          ((effect = next).flags & ReactiveFlags.watching) ==
              ReactiveFlags.none) {
        break;
      }
    } while (true);

    if (queuedEffectsTail == null) {
      queuedEffects = queuedEffectsTail = head;
    } else {
      queuedEffectsTail!.nextEffect = head;
      queuedEffectsTail = tail;
    }
  }

  @override
  void unwatched(ReactiveNode node) {
    if ((node.flags & ReactiveFlags.mutable) == ReactiveFlags.none) {
      stop(node);
    } else if (node.depsTail != null) {
      node.depsTail = null;
      node.flags =
          17 /*ReactiveFlags.mutable | ReactiveFlags.dirty*/ as ReactiveFlags;
      purgeDeps(node);
    }
  }
}

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
ReactiveNode? getActiveSub() => activeSub;

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
ReactiveNode? setActiveSub([ReactiveNode? sub]) {
  final prevSub = activeSub;
  activeSub = sub;
  return prevSub;
}

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
int getBatchDepth() => batchDepth;

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
void startBatch() {
  ++batchDepth;
}

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
void endBatch() {
  if ((--batchDepth) == 0) flush();
}

@pragma('vm:align-loops')
void trigger(void Function() fn) {
  final sub = ReactiveNode(flags: ReactiveFlags.watching),
      prevSub = setActiveSub(sub);
  try {
    fn();
  } finally {
    activeSub = prevSub;
    Link? link = sub.deps;
    while (link != null) {
      final dep = link.dep;
      link = unlink(link, sub);

      final subs = dep.subs;
      if (subs != null) {
        sub.flags = ReactiveFlags.none;
        propagate(subs);
        shallowPropagate(subs);
      }
    }
    if (batchDepth == 0) flush();
  }
}

void run(EffectNode e) {
  final flags = e.flags;
  if ((flags & ReactiveFlags.dirty) != ReactiveFlags.none ||
      ((flags & ReactiveFlags.pending) != ReactiveFlags.none &&
          checkDirty(e.deps!, e))) {
    ++cycle;
    e.depsTail = null;
    e.flags =
        6 /*ReactiveFlags.watching | ReactiveFlags.recursedCheck*/
            as ReactiveFlags;
    final prevSub = setActiveSub(e);
    try {
      e.fn();
    } finally {
      activeSub = prevSub;
      e.flags &= -5 /*~ReactiveFlags.recursedCheck*/;
      purgeDeps(e);
    }
  } else {
    e.flags = ReactiveFlags.watching;
  }
}

@pragma('vm:align-loops')
@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
void flush() {
  try {
    while (queuedEffects != null) {
      final effect = queuedEffects as EffectNode;
      queuedEffects = effect.nextEffect;
      effect.nextEffect = null;
      if (queuedEffects == null) {
        queuedEffectsTail = null;
      }
      run(effect);
    }
  } finally {
    for (var effect = queuedEffects; effect != null;) {
      final next = effect.nextEffect;
      effect.flags |=
          10 /*ReactiveFlags.watching | ReactiveFlags.recursed*/
              as ReactiveFlags;
      effect.nextEffect = null;
      effect = next;
    }
    queuedEffects = queuedEffectsTail = null;
  }
}

void stop(ReactiveNode node) {
  node.depsTail = null;
  node.flags = ReactiveFlags.none;
  purgeDeps(node);
  final subs = node.subs;
  if (subs != null) {
    unlink(subs, subs.sub);
  }
}

@pragma('vm:align-loops')
@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
void purgeDeps(ReactiveNode sub) {
  final depsTail = sub.depsTail;
  Link? dep = depsTail != null ? depsTail.nextDep : sub.deps;
  while (dep != null) {
    dep = unlink(dep, sub);
  }
}
