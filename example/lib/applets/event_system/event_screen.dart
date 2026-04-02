import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../../widgets/base_screen.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';

class EventScreen extends BaseScreen {
  // Signals for our event-driven example
  final counter = signal<int>(0);
  final userName = signal<String>('');
  final notifications = listSignal<String>([]);
  final isOnline = signal<bool>(true);

  @override
  String get title => 'Event System';

  @override
  Color get backgroundColor => Colors.pink;

  @override
  void init(BuildContext context) {
    // Event: Log whenever counter changes
    effect(() {
      if (counter() > 0) {
        notifications.add('Counter increased to ${counter()}');
      }
    });

    // Event: Handle online/offline status changes
    effect(() {
      final status = isOnline() ? 'online' : 'offline';
      notifications.add('User went $status');
    });

    // Event: Reset notifications when they reach 5
    effect(() {
      if (notifications().length >= 5) {
        Future.delayed(Duration(seconds: 1), () {
          notifications([]);
        });
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Online status toggle
        AppCard(
          child: Column(
            children: [
              Text(
                'Connection Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                isOnline() ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isOnline() ? Colors.green[900] : Colors.grey[700],
                ),
              ),
              SizedBox(height: 12),
              Switch(
                value: isOnline(),
                onChanged: (value) => isOnline(value),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Counter section
        AppCard(
          child: Column(
            children: [
              Text(
                'Event Counter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${counter()}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    text: '+',
                    icon: Icons.add,
                    onPressed: () => counter(counter() + 1),
                    backgroundColor: Colors.blue,
                  ),
                  SizedBox(width: 16),
                  AppButton(
                    text: '-',
                    icon: Icons.remove,
                    onPressed: () => counter(counter() - 1),
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Notifications section
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications (${notifications().length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple[800],
                ),
              ),
              SizedBox(height: 12),
              if (notifications().isEmpty)
                Text(
                  'No notifications',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notifications().length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              size: 16,
                              color: Colors.purple,
                            ),
                            SizedBox(width: 8),
                            Expanded(child: Text(notifications()[index])),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Clear notifications button
        Center(
          child: AppButton(
            text: 'Clear Notifications',
            icon: Icons.clear_all,
            onPressed: () => notifications([]),
            backgroundColor: Colors.purple,
          ),
        ),
      ],
    );
  }
}
