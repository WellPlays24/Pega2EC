import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../features/landing/presentation/pages/landing_page.dart';

void bootstrapApp() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Pega2EcApp());
}

class Pega2EcApp extends StatelessWidget {
  const Pega2EcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LandingPage(),
    );
  }
}
