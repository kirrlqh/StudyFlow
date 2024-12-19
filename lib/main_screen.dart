import 'package:flutter/material.dart';
import 'students_tab.dart';
import 'schools_tab.dart';
import 'results_tab.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная страница', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // Темный фон для AppBar
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.person, color: Colors.white),
              text: 'Ученики',
            ),
            Tab(
              icon: Icon(Icons.apartment, color: Colors.white),
              text: 'Школы',
            ),
            Tab(
              icon: Icon(Icons.assignment, color: Colors.white),
              text: 'Результаты',
            ),
          ],
          indicatorColor: Colors.blueAccent, // Цвет индикатора для активной вкладки
          labelColor: Colors.blueAccent, // Цвет текста для активной вкладки
          unselectedLabelColor: Colors.white, // Цвет текста для неактивных вкладок
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StudentsTab(),
          SchoolsTab(),
          ResultsTab(),
        ],
      ),
    );
  }
}
