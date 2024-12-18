import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultsTab extends StatefulWidget {
  @override
  _ResultsTabState createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> results = [];
  List<Map<String, dynamic>> filteredResults = [];
  bool isLoading = true;

  Future<String> fetchStudentName(int studentId) async {
    final response = await Supabase.instance.client
        .from('students')
        .select('name, surname')
        .eq('id', studentId)
        .single();

    if (response != null && response['name'] != null && response['surname'] != null) {
      return '${response['surname']} ${response['name']}';
    } else {
      return 'Неизвестно';
    }
  }

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
            'student': studentName,
            'score': result['score'],
            'numberschool': result['numberschool'],
            'dateevent': result['dateevent'],
            'subject': result['subject'],
          });
        }

        setState(() {
          results = fetchedResults;
          filteredResults = fetchedResults;
          isLoading = false;
        });
      } else {
        throw Exception('Ошибка загрузки результатов.');
      }
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
    fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Результаты студентов', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterResults,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.blueAccent, // Цвет курсора
                decoration: InputDecoration(
                  hintText: 'Поиск по фамилии или имени...',
                  hintStyle: TextStyle(color: Colors.white70),
                  labelText: 'Поиск',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : (filteredResults.isEmpty
                  ? Center(child: Text('Нет данных.', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)))
                  : ListView.builder(
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  final result = filteredResults[index];
                  return Card(
                    elevation: 8,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[850],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      title: Text(
                        result['student'] ?? 'Неизвестно',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      subtitle: Text(
                        'Школа №${result['numberschool']}, Предмет: ${result['subject']}, Балл: ${result['score']}, Дата: ${result['dateevent']}',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      leading: Icon(Icons.school, color: Colors.white),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
