import 'package:flutter/material.dart';
import 'home_page.dart';

// Splash Screen for BoscoPlanner
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nature, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'BoscoPlanner',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
          ],
        ),
      ),
    );
  }
}
