import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled/admin_screen.dart';
import 'package:untitled/curator_screen.dart';
import 'package:untitled/main_screen.dart';
import 'package:untitled/supabase_service.dart'; // Проверьте путь или уберите, если уже импортировано

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true; // Переменная для скрытия/показа пароля
  String? errorMessage;

  // Метод для авторизации с проверкой роли
  Future<void> _login() async {
    try {
      // Проверка в таблице loginadmin для администратора
      final adminResponse = await SupabaseService.client
          .from('loginadmin')
          .select()
          .eq('login', _loginController.text.trim())
          .maybeSingle();

      // Проверка в таблице logintutor для куратора
      final tutorResponse = await SupabaseService.client
          .from('logintutor')
          .select()
          .eq('login', _loginController.text.trim())
          .maybeSingle();

      // Проверка, найден ли пользователь в таблице loginadmin
      if (adminResponse != null &&
          adminResponse['password'] == _passwordController.text.trim()) {
        setState(() {
          errorMessage = null;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
        );
        return;
      }

      // Проверка, найден ли пользователь в таблице logintutor
      if (tutorResponse != null &&
          tutorResponse['password'] == _passwordController.text.trim()) {
        setState(() {
          errorMessage = null;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CuratorScreen()),
        );
        return;
      }

      // Если данные не совпадают, показываем ошибку
      setState(() {
        errorMessage = 'Неверный логин или пароль.';
      });
    } catch (e) {
      // Обработка ошибок
      setState(() {
        errorMessage = 'Ошибка: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _loginController,
              decoration: InputDecoration(labelText: 'Логин'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                ),
              ),
              obscureText: _isPasswordHidden,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text('Войти'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Переход на главный экран (без проверки логина)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
              child: Text('Перейти на главный экран'),
            ),
          ],
        ),
      ),
    );
  }
}
