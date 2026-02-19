import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/screens/splash/splash_screen.dart';
import 'package:market_mind/theme/app_theme.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(BrandModelAdapter());

  // Initialize BrandService
  await brandService.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
