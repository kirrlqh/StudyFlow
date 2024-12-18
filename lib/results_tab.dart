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
        title: Text('Результаты студентов'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterResults,
                    decoration: InputDecoration(
                      hintText: 'Поиск по фамилии или имени...',
                      labelText: 'Поиск',
                      prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : (filteredResults.isEmpty
                ? Center(child: Text('Нет данных.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)))
                : ListView.builder(
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final result = filteredResults[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      result['student'] ?? 'Неизвестно',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Школа №${result['numberschool']}, Предмет: ${result['subject']}, Балл: ${result['score']}, Дата: ${result['dateevent']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: Icon(Icons.school, color: Colors.deepPurple),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
