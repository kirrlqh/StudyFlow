import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultsTab extends StatefulWidget {
  @override
  _ResultsTabState createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> results = []; // Данные таблицы результатов
  List<Map<String, dynamic>> filteredResults = []; // Отфильтрованные результаты

  // Функция для получения данных из таблицы results
  Future<List<Map<String, dynamic>>> fetchResults() async {
    final response = await Supabase.instance.client
        .from('results')
        .select('id, studentid, score, numberschool, dateevent, subject, students(surname)');

    // Проверяем, является ли ответ списком
    if (response is List) {
      return List<Map<String, dynamic>>.from(response.map((result) {
        return {
          'id': result['id'],
          'student': result['students']['surname'], // Фамилия студента
          'score': result['score'],
          'numberschool': result['numberschool'],
          'dateevent': result['dateevent'],
          'subject': result['subject'],
        };
      }));
    } else {
      throw Exception('Ошибка загрузки результатов.');
    }
  }

  // Функция фильтрации по фамилии студента
  void _filterResults(String query) {
    final filtered = results.where((result) {
      final studentName = result['student']?.toLowerCase() ?? '';
      return studentName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredResults = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchResults(), // Получаем результаты с помощью fetchResults
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Показать индикатор загрузки
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}')); // Показать ошибку
        } else if (snapshot.hasData) {
          final results = snapshot.data!;
          // Изначально показываем все результаты
          if (filteredResults.isEmpty) {
            filteredResults = results;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Поиск по фамилии студента',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _filterResults(_searchController.text); // Запуск фильтрации по кнопке
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final result = filteredResults[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        title: Text(result['student'] ?? 'Неизвестно'),
                        subtitle: Text(
                          'Школа: ${result['numberschool']}, Предмет: ${result['subject']}, Балл: ${result['score']}, Дата: ${result['dateevent']}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return Center(child: Text('Нет данных.'));
        }
      },
    );
  }
}
