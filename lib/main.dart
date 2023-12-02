import 'package:flutter/material.dart';
import 'package:ride_tracker/Screen/ride_history_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RideHistoryScreen(),
    );
  }
}
