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
  bool isLoading = true; // Состояние загрузки данных

  // Функция для получения фамилий студентов
  Future<String> fetchStudentName(int studentId) async {
    final response = await Supabase.instance.client
        .from('students')
        .select('surname')
        .eq('id', studentId)
        .single();

    if (response != null && response['surname'] != null) {
      return response['surname'];
    } else {
      return 'Неизвестно'; // Если фамилия не найдена
    }
  }

  // Функция для получения данных из таблицы results
  Future<void> fetchResults() async {
    try {
      final response = await Supabase.instance.client
          .from('results')
          .select('id, studentid, score, numberschool, dateevent, subject');

      if (response is List) {
        List<Map<String, dynamic>> fetchedResults = [];

        for (var result in response) {
          final studentName = await fetchStudentName(result['studentid']);
          fetchedResults.add({
            'id': result['id'],
            'student': studentName, // Добавляем фамилию студента
            'score': result['score'],
            'numberschool': result['numberschool'],
            'dateevent': result['dateevent'],
            'subject': result['subject'],
          });
        }

        setState(() {
          results = fetchedResults;
          filteredResults = fetchedResults; // Изначально показываем все результаты
          isLoading = false; // Загрузка завершена
        });
      } else {
        throw Exception('Ошибка загрузки результатов.');
      }
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      setState(() {
        isLoading = false; // Завершаем загрузку даже в случае ошибки
      });
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
  void initState() {
    super.initState();
    fetchResults(); // Загружаем результаты при инициализации
  }

  @override
  Widget build(BuildContext context) {
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
          child: isLoading
              ? Center(child: CircularProgressIndicator()) // Показать индикатор загрузки
              : (filteredResults.isEmpty
              ? Center(child: Text('Нет данных.'))
              : ListView.builder(
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
          )),
        ),
      ],
    );
  }
}
