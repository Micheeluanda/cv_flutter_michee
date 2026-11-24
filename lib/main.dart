import 'package:material_ui/material_ui.dart';

import 'app/theme/app_theme.dart';
import 'core/api/api_service.dart';
import 'features/auth/login_page.dart';
import 'navigation/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.apiService});

  final ApiService? apiService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ApiService _apiService = widget.apiService ?? ApiService();
  bool _connected = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Michee Luanda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _connected
          ? MainNavigation(onLogout: () => setState(() => _connected = false))
          : LoginPage(
              apiService: _apiService,
              onLogin: () => setState(() => _connected = true),
            ),
    );
  }
}
