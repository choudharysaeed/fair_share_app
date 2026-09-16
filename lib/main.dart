import 'package:fair_share_app/providers/activity_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'providers/expence_provider.dart';
import 'providers/settlement_provider.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F75),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F8F7),
          foregroundColor: Color(0xFF172B3A),
          elevation: 0,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}