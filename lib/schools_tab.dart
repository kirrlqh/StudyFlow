import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolsTab extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchSchools() async {
    final response = await Supabase.instance.client.from('schools').select();
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      throw Exception('Ошибка загрузки школ.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
                title: Text('Школа №${school['number']}'),
                subtitle: Text('Адрес: ${school['address']}'),
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