import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(BoscoPlannerApp());
}

class BoscoPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoscoPlanner',
      theme: ThemeData(
        primarySwatch: Colors.green, // Colore principale dell'app (con i temi di verde)
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false, // Disabilita il banner di debug
    );
  }
}
