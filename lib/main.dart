import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/screens/splash/splash_screen.dart';
import 'package:market_mind/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(BrandModelAdapter());

  // Initialize BrandService
  await productService.init();

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
