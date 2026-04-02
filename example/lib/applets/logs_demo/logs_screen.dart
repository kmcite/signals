import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';

// Global logs signal
final logs = listSignal<String>([]);

void appendLog(String msg) {
  logs.value = [...logs.value, msg];
}

class LogsScreen extends BaseScreen {
  @override
  String get title => 'Activity Logs';

  @override
  Color get backgroundColor => Colors.teal;

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Add Sample Log',
                  icon: Icons.add,
                  onPressed: () {
                    final now = DateTime.now().toString().substring(0, 19);
                    appendLog('[$now] New log entry');
                  },
                  backgroundColor: Colors.teal,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Clear Logs',
                  icon: Icons.clear,
                  onPressed: () => logs([]),
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: logs().isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No logs yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Click "Add Sample Log" to create entries',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: logs().length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.message,
                            size: 16,
                            color: Colors.teal,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              logs()[index],
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
