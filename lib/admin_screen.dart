import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Админ панель'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Студенты'),
              Tab(text: 'Результаты'),
              Tab(text: 'Школы'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StudentsTab(),
            ResultsTab(),
            SchoolsTab(),
          ],
        ),
      ),
    );
  }
}

class StudentsTab extends StatelessWidget {
  Future<List<dynamic>> fetchStudents() async {
    final response = await Supabase.instance.client
        .from('students')
        .select()
        .then((value) => value as List<dynamic>);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text('${student['name']} ${student['surname']}'),
                subtitle: Text('Класс: ${student['class']}'),
              );
            },
          );
        } else {
          return Center(child: Text('Нет данных.'));
        }
      },
    );
  }
}

class ResultsTab extends StatelessWidget {
  Future<List<dynamic>> fetchResults() async {
    final response = await Supabase.instance.client
        .from('results')
        .select()
        .then((value) => value as List<dynamic>);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchResults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final results = snapshot.data!;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                title: Text('ID: ${result['id']}'),
                subtitle: Text('Результат: ${result['score']}'),
              );
            },
          );
        } else {
          return Center(child: Text('Нет данных.'));
        }
      },
    );
  }
}

class SchoolsTab extends StatelessWidget {
  Future<List<dynamic>> fetchSchools() async {
    final response = await Supabase.instance.client
        .from('schools')
        .select()
        .then((value) => value as List<dynamic>);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchSchools(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final schools = snapshot.data!;
          return ListView.builder(
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              return ListTile(
                title: Text('${school['name']}'),
                subtitle: Text('Город: ${school['city']}'),
              );
            },
          );
        } else {
          return Center(child: Text('Нет данных.'));
        }
      },
    );
  }
}
