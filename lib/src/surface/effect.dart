part of 'surface.dart';

abstract class Effect {
  void call();
}

Effect effect(void Function() fn) {
  final e = _EffectImpl(
        fn: fn,
        flags:
            6 /* ReactiveFlags.watching | ReactiveFlags.recursedCheck */
                as ReactiveFlags,
      ),
      prevSub = setActiveSub(e);
  if (prevSub != null) link(e, prevSub, 0);
  try {
    fn();
    return e;
  } finally {
    activeSub = prevSub;
    e.flags &= -5 /*~ ReactiveFlags.recursedCheck */;
  }
}

final class _EffectImpl extends EffectNode implements Effect {
  _EffectImpl({required super.flags, required super.fn});

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  void call() => stop(this);
}
