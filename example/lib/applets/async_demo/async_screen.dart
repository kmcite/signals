import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';

// Global async signals
final ticker = streamSignal<int>(
  Stream.periodic(Duration(seconds: 1), (i) => i),
  initialValue: 0,
);
final futureSig = futureSignal<String>(() async {
  await Future.delayed(Duration(seconds: 2));
  return 'fetched';
});

class AsyncScreen extends BaseScreen {
  @override
  String get title => 'Async Demo';

  @override
  Color get backgroundColor => Colors.green;

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientCard(
          colors: [
            Colors.green.withOpacity(0.3),
            Colors.green.withOpacity(0.6),
          ],
          child: Column(
            children: [
              Text(
                'Real-time Ticker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${ticker()}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Updates every second',
                style: TextStyle(fontSize: 14, color: Colors.green),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: AppButton(
            text: 'Auto-refreshing',
            icon: Icons.autorenew,
            onPressed: () {
              // nothing, ticker updates automatically
            },
            backgroundColor: Colors.green,
          ),
        ),
        SizedBox(height: 30),
        GradientCard(
          colors: [
            Colors.orange.shade100,
            Colors.orange.shade300,
          ],
          child: Column(
            children: [
              Text(
                'Future State',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${futureSig.state}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              if (futureSig.state.hasData && futureSig.state.value != null)
                Text(
                  futureSig().value!,
                  style: TextStyle(fontSize: 16, color: Colors.orange),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: AppButton(
            text: 'Refresh Future',
            icon: Icons.refresh,
            onPressed: () => futureSig.refresh(),
            backgroundColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}
