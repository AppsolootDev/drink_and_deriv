import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'src/pages/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    // Define the base text style with Josefine and 17px
    const baseTextStyle = TextStyle(
      fontFamily: 'Josefine',
      fontSize: 17,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Drink and Deryve',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Josefine', // Global default font
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
          primary: Color(0xFFBA8858), // camel
          onPrimary: Colors.white,
          secondary: Color(0xFFC4B5A6), // khaki-beige
          onSecondary: Color(0xFF0A0C08), // onyx
          surface: Colors.white,
          onSurface: Color(0xFF0A0C08), // onyx
          error: Colors.red,
          onError: Colors.white,
          outline: Color(0xFF3E2A1A), // dark-coffee
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 2, 
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          actionsIconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: 'Josefine',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBA8858), // camel
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontFamily: 'Josefine', fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'Josefine', fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'Josefine', fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A0C08), // onyx
          selectedItemColor: Color(0xFFBA8858), // camel
          unselectedItemColor: Color(0xFFC4B5A6), // khaki-beige
          selectedLabelStyle: TextStyle(fontFamily: 'Josefine', fontSize: 12),
          unselectedLabelStyle: TextStyle(fontFamily: 'Josefine', fontSize: 12),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          surfaceTintColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
