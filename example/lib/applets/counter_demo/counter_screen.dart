import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';

// Global signals used throughout the demo
final counters = mapSignal<int, int>();
final count = computed(
  () {
    int total = 0;
    for (var entry in counters.entries) {
      total += entry.key + entry.value;
    }
    return total;
  },
);

// two signals to illustrate batching/untracked/peek
final a = signal<int>(0);
final b = signal<int>(0);

void addLots() {
  batch(() {
    for (var i = 0; i < 5; ++i) {
      counters[i] = i;
    }
  });
}

class CounterScreen extends BaseScreen {
  @override
  String get title => 'Counter Demo';

  @override
  Color get backgroundColor => Colors.blue;

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientCard(
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.blue.withOpacity(0.6),
          ],
          child: Column(
            children: [
              Text(
                'Total Count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${count()}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: AppButton(
            text: 'Add Lots',
            icon: Icons.add,
            onPressed: addLots,
            backgroundColor: Colors.blue,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Individual Counters',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Flexible(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var entry in counters.entries)
                Chip(
                  label: Text('${entry.key}: ${entry.value}'),
                  deleteIcon: Icon(Icons.close, size: 18),
                  onDeleted: () => counters.remove(entry.key),
                  backgroundColor: Colors.blue.withOpacity(0.3),
                  labelStyle: TextStyle(fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Text(
          'Reactivity Demo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tracked access:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text('counters: ${count()}'),
              SizedBox(height: 8),
              Text(
                'Untracked access:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text('peek counters: ${counters.peek()}'),
            ],
          ),
        ),
      ],
    );
  }
}
