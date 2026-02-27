import 'link.dart';
import 'reactive_flags.dart';

class ReactiveNode {
  ReactiveFlags flags;
  Link? deps;
  Link? depsTail;
  Link? subs;
  Link? subsTail;

  ReactiveNode({
    required this.flags,
    this.deps,
    this.depsTail,
    this.subs,
    this.subsTail,
  });
}
