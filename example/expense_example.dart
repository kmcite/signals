import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

// Expense model
class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  // Make Expense reactive by wrapping mutable fields in signals if needed
  @override
  String toString() => '$title: \$${amount.toStringAsFixed(2)} ($category)';
}

// Expense Repository - holds the source of truth for expenses
class ExpenseRepository {
  final Signal<List<Expense>> _expenses = signal<List<Expense>>([]);

  Signal<List<Expense>> get expensesSignal => _expenses;
  List<Expense> get expenses => _expenses();

  void addExpense(Expense expense) {
    _expenses([..._expenses(), expense]);
  }

  void removeExpense(String id) {
    _expenses(_expenses().where((e) => e.id != id).toList());
  }

  void updateExpense(
    String id, {
    String? title,
    double? amount,
    String? category,
  }) {
    final updatedExpenses = _expenses().map((e) {
      if (e.id == id) {
        return Expense(
          id: e.id,
          title: title ?? e.title,
          amount: amount ?? e.amount,
          date: e.date,
          category: category ?? e.category,
        );
      }
      return e;
    }).toList();
    _expenses(updatedExpenses);
  }
}

// Expense ViewModel - exposes data and operations to the UI
class ExpenseViewModel {
  final ExpenseRepository _repo;

  // Computed values
  late final Computed<double> totalAmount;
  late final Computed<Map<String, double>> categoryTotals;
  late final Computed<List<Expense>> sortedExpenses;

  ExpenseViewModel(this._repo) {
    totalAmount = computed(() {
      return _repo.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    });

    categoryTotals = computed(() {
      final totals = <String, double>{};
      for (final expense in _repo.expenses) {
        totals[expense.category] =
            (totals[expense.category] ?? 0) + expense.amount;
      }
      return totals;
    });

    sortedExpenses = computed(() {
      final sorted = List<Expense>.from(_repo.expenses);
      sorted.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort by date descending
      return sorted;
    });
  }

  Signal<List<Expense>> get expenses => _repo.expensesSignal;
  double get total => totalAmount();
  Map<String, double> get categorySums => categoryTotals();
  List<Expense> get sortedExpenseList => sortedExpenses();

  void add(Expense expense) => _repo.addExpense(expense);
  void remove(String id) => _repo.removeExpense(id);
  void update(String id, {String? title, double? amount, String? category}) =>
      _repo.updateExpense(id, title: title, amount: amount, category: category);
}

// Expense Tracker UI
class ExpenseTrackerApp extends UI {
  final ExpenseViewModel vm;

  ExpenseTrackerApp(this.vm);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExpenseTrackerPage(vm: vm),
    );
  }
}

class ExpenseTrackerPage extends UI {
  final ExpenseViewModel vm;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  ExpenseTrackerPage({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker (\$${vm.total.toStringAsFixed(2)})'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Add expense form
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Expense Title'),
                  ),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final title = _titleController.text.trim();
                      final amountStr = _amountController.text.trim();
                      final category = _categoryController.text.trim();

                      if (title.isEmpty ||
                          amountStr.isEmpty ||
                          category.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all fields')),
                        );
                        return;
                      }

                      final amount = double.tryParse(amountStr);
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid amount'),
                          ),
                        );
                        return;
                      }

                      final expense = Expense(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        amount: amount,
                        date: DateTime.now(),
                        category: category,
                      );

                      vm.add(expense);

                      // Clear form
                      _titleController.clear();
                      _amountController.clear();
                      _categoryController.clear();

                      // Hide keyboard
                      FocusScope.of(context).unfocus();
                    },
                    child: Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Summary cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard(
                  'Total',
                  '\$${vm.total.toStringAsFixed(2)}',
                  Colors.blue,
                ),
                _buildSummaryCard(
                  'Expenses',
                  vm.expenses().length.toString(),
                  Colors.green,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Category breakdown
          if (vm.categorySums.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Category Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: vm.categorySums.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: _buildCategoryCard(
                      entry.key,
                      '\$${entry.value.toStringAsFixed(2)}',
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
          ],

          // Expense list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: _buildExpenseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      width: 150,
      child: Card(
        color: color,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, String amount) {
    return Container(
      width: 120,
      child: Card(
        color: Colors.orange,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    final expenses = vm.sortedExpenseList;

    if (expenses.isEmpty) {
      return Center(
        child: Text(
          'No expenses yet\nAdd your first expense!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Dismissible(
          key: Key(expense.id),
          onDismissed: (_) => vm.remove(expense.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  expense.category.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(expense.title),
              subtitle: Text(
                '${expense.date.day}/${expense.date.month}/${expense.date.year} • ${expense.category}',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Example usage
void main() {
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

  runApp(ExpenseTrackerApp(vm));
}
