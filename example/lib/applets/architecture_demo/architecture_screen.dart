import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../../architecture_example.dart';

class ArchitectureScreen extends BaseScreen {
  late final TodoRepository _repo;
  late final TodoViewModel _vm;

  @override
  String get title => 'Architecture Demo';

  @override
  Color get backgroundColor => Colors.indigo;

  @override
  void init(BuildContext context) {
    _repo = TodoRepository();
    _vm = TodoViewModel(_repo);
  }

  @override
  Widget buildBody(BuildContext context) {
    return TodoPage(vm: _vm);
  }
}
