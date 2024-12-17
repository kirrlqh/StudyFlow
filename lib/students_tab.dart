import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsTab extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchStudents() async {
    final response = await Supabase.instance.client.from('students').select();
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      throw Exception('Ошибка загрузки студентов.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
                subtitle: Text('Класс: ${student['class']}, Школа №${student['numberschool']}'),
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
