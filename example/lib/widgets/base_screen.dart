import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'app_bar.dart';

abstract class BaseScreen extends UI {
  String get title;
  Color get backgroundColor => Colors.blue;
  Color get textColor => Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context);
}

abstract class BaseGridScreen extends UI {
  String get title;
  Color get backgroundColor => Colors.blue;
  Color get textColor => Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context);
}
