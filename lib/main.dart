
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/database_helper.dart';
import 'screens/login.dart';
import 'screens/otp.dart';
import 'screens/profile_setup.dart';
import 'screens/home.dart';
import 'screens/messages.dart';
import 'screens/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite for Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  // Initialize unified database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  
  runApp(const ConnectUApp());
}

class ConnectUApp extends StatelessWidget {
  const ConnectUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/otp': (context) => const OTPScreen(),
        '/setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
