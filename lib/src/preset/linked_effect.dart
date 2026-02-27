import 'reactive_node.dart';

class LinkedEffect extends ReactiveNode {
  LinkedEffect? nextEffect;
  LinkedEffect({
    required super.flags,
    super.deps,
    super.depsTail,
    super.subs,
    super.subsTail,
  });
}
