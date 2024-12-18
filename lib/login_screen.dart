import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled/admin_screen.dart';
import 'package:untitled/curator_screen.dart';
import 'package:untitled/main_screen.dart';
import 'package:untitled/supabase_service.dart';

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
      backgroundColor: Colors.grey[900], // Темный серый фон
      appBar: AppBar(
        backgroundColor: Colors.grey[850], // Более светлый черный фон для AppBar
        title: Text(
          'Авторизация',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            SizedBox(height: 40),
            _buildTextField(
              controller: _loginController,
              label: 'Логин',
              icon: Icons.person,
              obscureText: false,
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              label: 'Пароль',
              icon: Icons.lock,
              obscureText: _isPasswordHidden,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white, // Белая иконка видимости
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordHidden = !_isPasswordHidden;
                  });
                },
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            SizedBox(height: 24),
            _buildLoginButton(),
            SizedBox(height: 16),
            _buildResultsButton(),
          ],
        ),
      ),
    );
  }

  // Логотип
  Widget _buildLogo() {
    return Column(
      children: [
        Icon(
          Icons.account_circle,
          size: 100,
          color: Colors.white, // Белый цвет для логотипа
        ),
        Text(
          'Добро пожаловать',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Белый текст
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Пожалуйста, войдите в свою учетную запись',
          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
        ),
      ],
    );
  }

  // Стильное текстовое поле с иконкой
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white), // Белый текст в поле ввода
      cursorColor: Colors.blueAccent, // Синий цвет курсора
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white), // Белая метка
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[800], // Темно-серый фон для поля ввода
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
        ),
      ),
    );
  }

  // Кнопка входа с более светлым цветом
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      child: Text(
        'Войти',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent, // Синий для кнопки
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0), // Более сглаженные углы
        ),
        elevation: 5.0,
        minimumSize: Size(double.infinity, 50),
        shadowColor: Colors.blueAccent.withOpacity(0.4),
      ),
    );
  }

  // Кнопка "Результаты"
  Widget _buildResultsButton() {
    return ElevatedButton(
      onPressed: () {
        // Переход на экран результатов
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      },
      child: Text(
        'Результаты',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[700], // Темная кнопка для результатов
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 4.0,
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}
