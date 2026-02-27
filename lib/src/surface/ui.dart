part of 'surface.dart';

abstract class UI extends StatefulWidget {
  const UI({super.key});

  Widget build(BuildContext context);

  void init(BuildContext context) {}

  void dispose() {}

  @override
  State<UI> createState() => _UIState();
}

class _UIState extends State<UI> {
  Effect? _effect;
  Widget _child = const SizedBox();

  bool _initialized = false;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      widget.init(context);
      _initialized = true;
    }

    _effect?.call();

    _effect = effect(() {
      _child = widget.build(context);
      _scheduleRebuild();
    });
  }

  void _scheduleRebuild() {
    if (_scheduled || !mounted) return;

    _scheduled = true;

    scheduleMicrotask(() {
      if (!mounted) return;

      _scheduled = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _effect?.call();
    widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _child;
}
