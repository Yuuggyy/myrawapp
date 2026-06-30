import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyRawApp());
}

class MyRawApp extends StatefulWidget {
  const MyRawApp({super.key});

  static _MyRawAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyRawAppState>();

  @override
  State<MyRawApp> createState() => _MyRawAppState();
}

class _MyRawAppState extends State<MyRawApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyRawApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}
