import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';

// parameterized computed example
final square = paramComputed<int, int>(
  builder: (x) => x * x,
);

class ParamScreen extends BaseScreen {
  @override
  String get title => 'Parameterized Demo';

  @override
  Color get backgroundColor => Colors.orange;

  @override
  Widget buildBody(BuildContext context) {
    final handle = square(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parameterized Computed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 16),
              Text('param = 2, square = ${handle.computed()}'),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Increment Param',
                      onPressed: () =>
                          handle.updateParam(handle.computed() + 1),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: 'Dispose',
                      onPressed: handle.dispose,
                      backgroundColor: Colors.red,
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
                'How It Works',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Parameterized computed signals allow you to create computed values based on parameters. '
                'They create a new computation when the parameter changes.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
