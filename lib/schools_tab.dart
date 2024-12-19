import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolsTab extends StatefulWidget {
  @override
  _SchoolsTabState createState() => _SchoolsTabState();
}

class _SchoolsTabState extends State<SchoolsTab> {
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
        // Пока данные загружаются, устанавливаем темный фон
        return Scaffold(
          appBar: AppBar(
            title: Text('Школы', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          backgroundColor: Colors.black,  // Темный фон для всего экрана
          body: Container(
            color: Colors.black,  // Темный фон для всей страницы
            padding: EdgeInsets.all(16),
            child: snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : snapshot.hasError
                ? Center(child: Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white)))
                : snapshot.hasData
                ? ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final school = snapshot.data![index];
                return Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  color: Colors.grey[850], // Темный фон для карточки
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    leading: Icon(Icons.apartment, color: Colors.blueAccent), // Яркая иконка
                    title: Text(
                      'Школа №${school['number']}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    subtitle: Text(
                      'Адрес: ${school['address']}',
                      style: TextStyle(fontSize: 14, color: Colors.white70), // Светлый текст для подзаголовка
                    ),
                  ),
                );
              },
            )
                : Center(child: Text('Нет данных.', style: TextStyle(color: Colors.white))),
          ),
        );
      },
    );
  }
}
