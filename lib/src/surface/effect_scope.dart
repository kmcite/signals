part of 'surface.dart';

@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
abstract class EffectScope {
  void call();
}

EffectScope effectScope(void Function() fn) {
  final e = _EffectScopeImpl(flags: ReactiveFlags.none),
      prevSub = setActiveSub(e);
  if (prevSub != null) link(e, prevSub, 0);
  try {
    fn();
    return e;
  } finally {
    activeSub = prevSub;
  }
}

class _EffectScopeImpl extends ReactiveNode implements EffectScope {
  _EffectScopeImpl({required super.flags});

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  void call() => stop(this);
}
