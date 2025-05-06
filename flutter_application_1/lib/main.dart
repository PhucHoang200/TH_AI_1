import 'package:flutter/material.dart';
import 'package:flutter_application_1/heuricstic_optimal_search.dart';
import 'package:flutter_application_1/minimax_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graph Search Algorithms',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MinimaxScreen(),
    );
  }
}
