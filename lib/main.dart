import 'package:flutter/material.dart';
import 'package:untitled/login_screen.dart';
import 'package:untitled/supabase_service.dart';
import 'package:untitled/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize(); // Инициализация Supabase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Авторизация',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),  // Экран авторизации
        '/main': (context) => MainScreen(),  // Основной экран
      },
    );
  }
}
