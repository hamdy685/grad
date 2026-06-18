import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

import 'dart:async';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    print("=== APP STARTING ===");

    FlutterError.onError = (FlutterErrorDetails details) {
      print("Flutter Error: ${details.exceptionAsString()}");
      FlutterError.presentError(details);
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const FruiteApp(),
      ),
    );
  }, (error, stack) {
    print("Uncaught Exception: $error");
    print(stack);
  });
}

class FruiteApp extends StatelessWidget {
  const FruiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruite AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode as requested
      builder: (context, child) {
        return Container(
          color: Colors.black, // Desktop background
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ClipRect(
                child: child ?? const SizedBox(),
              ),
            ),
          ),
        );
      },
      home: const SplashScreen(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
