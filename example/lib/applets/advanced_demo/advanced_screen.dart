import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';

// Import global signals from counter demo
final a = signal<int>(0);
final b = signal<int>(0);

class AdvancedScreen extends BaseScreen {
  @override
  String get title => 'Advanced Features';

  @override
  Color get backgroundColor => Colors.purple;

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Values',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 16),
              Text('a = ${a()}  b = ${b()}'),
            ],
          ),
        ),
        SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Individual Updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Inc a',
                      onPressed: () => a(a() + 1),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: 'Inc b',
                      onPressed: () => b(b() + 1),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Batch Update',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Update both a and b together without intermediate reactions',
              ),
              SizedBox(height: 16),
              AppButton(
                text: 'Batch ++',
                onPressed: () {
                  batch(() {
                    a(a() + 1);
                    b(b() + 1);
                  });
                },
                backgroundColor: Colors.purple,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advanced Access Patterns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              Text('Untracked read of a: ${untracked(() => a())}'),
              Text('Peek b: ${b.peek()}'),
              SizedBox(height: 16),
              Text(
                'untracked() - reads without tracking dependencies\n'
                'peek() - reads without causing reactivity',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
