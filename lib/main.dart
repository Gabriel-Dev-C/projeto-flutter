import 'package:flutter/material.dart';
import 'package:projeto_flutter/theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FitStartApp());
}

class FitStartApp extends StatelessWidget {
  const FitStartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitStart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
