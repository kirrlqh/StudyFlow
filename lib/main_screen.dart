import 'package:flutter/material.dart';
import 'students_tab.dart';
import 'schools_tab.dart';
import 'results_tab.dart';

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
        title: Text('Главная страница'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Ученики'),
            Tab(text: 'Школы'),
            Tab(text: 'Результаты'),
          ],
        ),
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
