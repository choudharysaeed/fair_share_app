import 'package:fair_share_app/providers/activity_provider.dart';
import 'package:fair_share_app/providers/home_provider.dart';
import 'package:fair_share_app/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'providers/expence_provider.dart';
import 'providers/settlement_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => GroupProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => ExpenseProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => SettlementProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ActivityProvider(),
        ),
        ChangeNotifierProvider(
          create: (context)=>HomeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF087F75),
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF4F8F7),
              foregroundColor: Color(0xFF172B3A),
              elevation: 0,
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F8F7),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF087F75),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF101918),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            scaffoldBackgroundColor: const Color(0xFF101918),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}