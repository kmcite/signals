extension type const ReactiveFlags._(int _) implements int {
  static const none = 0 as ReactiveFlags;
  static const mutable = 1 as ReactiveFlags;
  static const watching = 2 as ReactiveFlags;
  static const recursedCheck = 4 as ReactiveFlags;
  static const recursed = 8 as ReactiveFlags;
  static const dirty = 16 as ReactiveFlags;
  static const pending = 32 as ReactiveFlags;

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  ReactiveFlags operator |(int other) => _ | other as ReactiveFlags;

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  ReactiveFlags operator &(int other) => _ & other as ReactiveFlags;

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  @pragma('wasm:prefer-inline')
  ReactiveFlags operator ~() => ~_ as ReactiveFlags;
}
