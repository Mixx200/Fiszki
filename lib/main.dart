import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/edit_set_screen.dart';

void main() {
  runApp(const CognitoApp());
}

class CognitoApp extends StatelessWidget {
  const CognitoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognito Fiszki',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Ujednolicenie przycisków
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: HomeScreen(), // Zaczynamy od ekranu głównego
      debugShowCheckedModeBanner: false,
    );
  }
}