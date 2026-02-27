import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

void main() {
  runApp(ExampleApplication());
}

final count = signal(0);

class ExampleApplication extends UI {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enhanced Spark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CounterPage(),
    );
  }
}

class CounterPage extends UI {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enhanced Spark Counter'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => count(count() + 1),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${count()}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // FilledButton(
                //   onPressed: () => spark.increment(),
                //   child: Text('Increment'),
                // ),
                // FilledButton(
                //   onPressed: () => spark.decrement(),
                //   child: Text('Decrement'),
                // ),
                // FilledButton(
                //   onPressed: () => spark.reset(),
                //   child: Text('Reset'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
