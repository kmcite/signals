import 'package:flutter/material.dart';
import 'views/dashboard.dart';
import 'applets/counter_demo/counter_screen.dart';
import 'applets/async_demo/async_screen.dart';
import 'applets/param_demo/param_screen.dart';
import 'applets/advanced_demo/advanced_screen.dart';
import 'applets/logs_demo/logs_screen.dart';
import 'applets/architecture_demo/architecture_screen.dart';
import 'applets/expense_tracker/expense_screen.dart';
import 'applets/event_system/event_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case '/counter':
        return MaterialPageRoute(builder: (_) => CounterScreen());
      case '/async':
        return MaterialPageRoute(builder: (_) => AsyncScreen());
      case '/param':
        return MaterialPageRoute(builder: (_) => ParamScreen());
      case '/advanced':
        return MaterialPageRoute(builder: (_) => AdvancedScreen());
      case '/logs':
        return MaterialPageRoute(builder: (_) => LogsScreen());
      case '/architecture':
        return MaterialPageRoute(builder: (_) => ArchitectureScreen());
      case '/expense':
        return MaterialPageRoute(builder: (_) => ExpenseScreen());
      case '/event':
        return MaterialPageRoute(builder: (_) => EventScreen());
      default:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
    }
  }
}
