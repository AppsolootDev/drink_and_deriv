import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:showcaseview/showcaseview.dart';
import 'src/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found or failed to load: $e");
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseTextStyle = TextStyle(
      fontFamily: 'Josefine',
      fontSize: 17,
    );

    return ShowCaseWidget(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'Drink and Deryve',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Josefine',
          textTheme: const TextTheme(
            bodyLarge: baseTextStyle,
            bodyMedium: baseTextStyle,
            bodySmall: TextStyle(fontFamily: 'Josefine', fontSize: 14), 
            titleLarge: TextStyle(fontFamily: 'Josefine', fontSize: 22, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontFamily: 'Josefine', fontSize: 19, fontWeight: FontWeight.w600),
            titleSmall: TextStyle(fontFamily: 'Josefine', fontSize: 17, fontWeight: FontWeight.w500),
            labelLarge: baseTextStyle,
            labelMedium: baseTextStyle,
            labelSmall: baseTextStyle,
          ),
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFFBA8858),
            onPrimary: Colors.white,
            secondary: Color(0xFFC4B5A6),
            onSecondary: Color(0xFF0A0C08),
            surface: Colors.white,
            onSurface: Color(0xFF0A0C08),
            error: Colors.red,
            onError: Colors.white,
            outline: Color(0xFF3E2A1A),
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 2, 
            shadowColor: Colors.black12,
            surfaceTintColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xFFBA8858)),
            actionsIconTheme: IconThemeData(color: Color(0xFFBA8858)),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'Josefine',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA8858),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontFamily: 'Josefine', fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 2,
            surfaceTintColor: Colors.white,
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}
