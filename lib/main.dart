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
        primarySwatch: Colors.blue, // Основной цвет приложения
        brightness: Brightness.light, // Светлая тема
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue), // Цвет границы при фокусе
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Цвет границы по умолчанию
          ),
          labelStyle: TextStyle(color: Colors.grey), // Цвет метки
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue, // Цвет курсора
          selectionColor: Colors.blue.withOpacity(0.5), // Цвет выделения текста
          selectionHandleColor: Colors.blue, // Цвет маркеров выделения
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // Экран авторизации
        '/main': (context) => MainScreen(), // Основной экран
      },
    );
  }
}
