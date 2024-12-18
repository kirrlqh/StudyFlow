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
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(student['name'][0]),
                  ),
                  title: Text(
                    '${student['name']} ${student['surname']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Класс: ${student['class']}, Школа №${student['numberschool']}'),
                ),
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
