import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsTab extends StatefulWidget {
  @override
  _StudentsTabState createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;

  Future<void> fetchStudents() async {
    try {
      final response = await Supabase.instance.client.from('students').select();
      if (response is List) {
        setState(() {
          students = List<Map<String, dynamic>>.from(response);
          filteredStudents = students;
          isLoading = false;
        });
      } else {
        throw Exception('Ошибка загрузки студентов.');
      }
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    final filtered = students.where((student) {
      final fullName = '${student['name']} ${student['surname']}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredStudents = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ученики', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // Темный фон для AppBar
        elevation: 0,
      ),
      body: Container(
        color: Colors.black, // Темный фон для всей страницы
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterStudents,
                style: TextStyle(color: Colors.white), // Белый текст в поле поиска
                cursorColor: Colors.blueAccent, // Цвет курсора
                decoration: InputDecoration(
                  hintText: 'Поиск по фамилии или имени...',
                  hintStyle: TextStyle(color: Colors.white70), // Светлый текст подсказки
                  labelText: 'Поиск',
                  labelStyle: TextStyle(color: Colors.white), // Белая метка
                  prefixIcon: Icon(Icons.search, color: Colors.white), // Белая иконка
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
                  ? Center(child: CircularProgressIndicator(color: Colors.white)) // Белый индикатор
                  : (filteredStudents.isEmpty
                  ? Center(child: Text('Нет данных.', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)))
                  : ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  return Card(
                    elevation: 8,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[850], // Темный фон для карточки
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      title: Text(
                        '${student['name']} ${student['surname']}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      subtitle: Text(
                        'Класс: ${student['class']}, Школа №${student['numberschool']}',
                        style: TextStyle(color: Colors.white70), // Светлый цвет для подзаголовка
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent, // Яркий цвет для аватаров
                        child: Text(
                          student['name'][0],
                          style: TextStyle(color: Colors.white), // Белый цвет текста в аватаре
                        ),
                      ),
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
