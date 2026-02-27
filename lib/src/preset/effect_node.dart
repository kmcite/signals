import 'linked_effect.dart';

class EffectNode extends LinkedEffect {
  final void Function() fn;

  EffectNode({required super.flags, required this.fn});
}
