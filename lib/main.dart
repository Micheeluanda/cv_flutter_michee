import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'navigation/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _connected = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Michee Luanda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _connected
          ? const MainNavigation()
          : LoginPage(onLogin: () => setState(() => _connected = true)),
    );
  }
}
