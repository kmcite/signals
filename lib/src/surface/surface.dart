import 'dart:async';
import 'dart:collection';
import 'dart:math';

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
part 'map.dart';
part 'list.dart';
part 'stream.dart';
part 'future.dart';
part 'parameterized_computed.dart';

/// Helpers for controlling the reactive system.
///
/// - **batch**: run a set of writes inside a single batch so that effects are
///   flushed only once at the end.
/// - **untracked**: evaluate a callback without tracking any dependencies.
///
/// There are also lower‑level primitives in [system.dart] (e.g. [startBatch],
/// [endBatch], [trigger]) but these helpers are easier to use from client
/// code.

/// Execute [fn] inside a reactivity batch.
///
/// While the batch is active any notifications produced by signal writes are
/// queued.  Once all nested batches complete the engine runs every enqueued
/// effect exactly once.  This is useful when performing multiple updates and
/// you don't want intermediate reactions.
@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
R batch<R>(R Function() fn) {
  startBatch();
  try {
    return fn();
  } finally {
    endBatch();
  }
}

/// Run [fn] with dependency tracking disabled.
///
/// Reads of `Signal` or `Computed` values inside the callback will not
/// register the caller as a dependent.  This is handy for caching, debug
/// logging, or any other scenario where you want a one‑off inspection without
/// affecting the reactive graph.
@pragma('vm:prefer-inline')
@pragma('dart2js:tryInline')
@pragma('wasm:prefer-inline')
R untracked<R>(R Function() fn) {
  final prev = activeSub;
  activeSub = null;
  try {
    return fn();
  } finally {
    activeSub = prev;
  }
}
