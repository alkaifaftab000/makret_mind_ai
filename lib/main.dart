import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/screens/splash/splash_screen.dart';
import 'package:market_mind/theme/app_theme.dart';
import 'package:market_mind/utils/theme_transition_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// GoogleFonts.config.allowRuntimeFetching = false; // commented out to allow fetching Poppins from network on web

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(BrandModelAdapter());

  // Initialize BrandService
  await productService.init();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static void toggleTheme(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainAppState>();
    state?.toggleTheme();
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        final brightness = MediaQuery.of(context).platformBrightness;
        _themeMode = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      } else {
        _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Mind',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      builder: (context, child) {
        return RepaintBoundary(
          key: ThemeTransitionService.repaintBoundaryKey,
          child: child ?? const SizedBox(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
