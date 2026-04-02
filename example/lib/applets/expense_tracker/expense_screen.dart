import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../../expense_example.dart';

class ExpenseScreen extends BaseScreen {
  @override
  String get title => 'Expense Tracker';

  @override
  Color get backgroundColor => Colors.deepOrange;

  @override
  Widget buildBody(BuildContext context) {
    final repo = ExpenseRepository();
    final vm = ExpenseViewModel(repo);

    // Add some sample expenses
    repo.addExpense(
      Expense(
        id: '1',
        title: 'Groceries',
        amount: 45.67,
        date: DateTime.now().subtract(Duration(days: 1)),
        category: 'Food',
      ),
    );

    repo.addExpense(
      Expense(
        id: '2',
        title: 'Gas',
        amount: 35.00,
        date: DateTime.now().subtract(Duration(days: 2)),
        category: 'Transportation',
      ),
    );

    return ExpenseTrackerPage(vm: vm);
  }
}
