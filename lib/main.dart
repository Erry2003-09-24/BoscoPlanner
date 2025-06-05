import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(BoscoPlannerApp());
}

class BoscoPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoscoPlanner GPS',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
