import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const AppCard({
    Key? key,
    required this.child,
    this.color,
    this.elevation = 4,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: elevation,
      margin: margin,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const GradientCard({
    Key? key,
    required this.child,
    this.colors = const [
      Color.fromRGBO(220, 220, 220, 0.3),
      Color.fromRGBO(180, 180, 180, 0.6),
    ],
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
