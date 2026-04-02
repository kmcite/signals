import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../widgets/grid_item_card.dart';

class DashboardScreen extends BaseGridScreen {
  @override
  String get title => 'Signals Examples Dashboard';

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          GridItemCard(
            title: 'Counter Demo',
            icon: Icons.numbers,
            color: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, '/counter');
            },
          ),
          GridItemCard(
            title: 'Async Demo',
            icon: Icons.sync,
            color: Colors.green,
            onTap: () {
              Navigator.pushNamed(context, '/async');
            },
          ),
          GridItemCard(
            title: 'Parameterized',
            icon: Icons.functions,
            color: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, '/param');
            },
          ),
          GridItemCard(
            title: 'Advanced Features',
            icon: Icons.settings,
            color: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, '/advanced');
            },
          ),
          GridItemCard(
            title: 'Activity Logs',
            icon: Icons.list_alt,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/logs');
            },
          ),
          GridItemCard(
            title: 'Architecture',
            icon: Icons.architecture,
            color: Colors.indigo,
            onTap: () {
              Navigator.pushNamed(context, '/architecture');
            },
          ),
          GridItemCard(
            title: 'Expense Tracker',
            icon: Icons.monetization_on,
            color: Colors.deepOrange,
            onTap: () {
              Navigator.pushNamed(context, '/expense');
            },
          ),
          GridItemCard(
            title: 'Event System',
            icon: Icons.event,
            color: Colors.pink,
            onTap: () {
              Navigator.pushNamed(context, '/event');
            },
          ),
        ],
      ),
    );
  }
}
