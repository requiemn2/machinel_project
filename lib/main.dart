import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:machinel_project/screens/my_splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Mask Detector',
      home: MySplashScreen(),
    );
  }
}
