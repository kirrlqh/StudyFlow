import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; // Импортируем экран авторизации

/// ------------------- Экран "Куратор" -------------------
class CuratorScreen extends StatefulWidget {
  @override
  _CuratorScreenState createState() => _CuratorScreenState();
}

class _CuratorScreenState extends State<CuratorScreen> {
  late Future<List<dynamic>> results;

  Future<List<dynamic>> fetchResults() async {
    try {
      final response = await Supabase.instance.client
          .from('results')
          .select('''
          id, 
          score, 
          dateevent, 
          subject, 
          student:students(id, name, surname), 
          numberschool:schools(id, number)
        ''')
          .then((value) => value as List<dynamic>);
      return response;
    } catch (e) {
      throw Exception('Ошибка при загрузке данных: $e');
    }
  }

  Future<void> deleteResult(int id) async {
    await Supabase.instance.client.from('results').delete().eq('id', id);
    setState(() {
      results = fetchResults();
    });
  }

  Future<void> addResult(Map<String, dynamic> result) async {
    await Supabase.instance.client.from('results').insert({
      'score': result['score'],
      'dateevent': result['dateevent'],
      'subject': result['subject'],
      'studentid': result['studentid'],
      'numberschool': result['numberschool'],
    });
    setState(() {
      results = fetchResults();
    });
  }

  Future<void> editResult(int id, Map<String, dynamic> result) async {
    print("Редактируем результат с ID $id: $result");
    await Supabase.instance.client.from('results').update(result).eq('id', id);
    setState(() {
      results = fetchResults();
    });
  }

  @override
  void initState() {
    super.initState();
    results = fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Темный фон
      appBar: AppBar(
        backgroundColor: Colors.grey[850], // Темный цвет для AppBar
        title: Text(
          'Кураторская панель',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          // Кнопка для возврата на страницу авторизации
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildTab(
                context,
                results,
                    (item) =>
                'Результат: ${item['score']} | Ученик: ${item['student']['name']} ${item['student']['surname']}',
                    (item) =>
                'Дата: ${item['dateevent']} | Предмет: ${item['subject']} | Школа: ${item['numberschool']['number']}',
                deleteResult,
              ),
            ),
          ],
        ),
      ),
      // Кнопка "Добавить результат" снизу справа
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context, 'Добавить результат', {
            'score': '',
            'dateevent': '',
            'subject': '',
          }, addResult);
        },
        backgroundColor: Colors.blue, // Цвет кнопки
        child: Icon(Icons.add, color: Colors.white), // Иконка "+"
      ),
    );
  }

  // Общий виджет для отображения таба
  Widget _buildTab(
      BuildContext context,
      Future<List<dynamic>> future,
      String Function(Map<String, dynamic>) titleBuilder,
      String Function(Map<String, dynamic>) subtitleBuilder,
      void Function(int) onDelete,
      ) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))); // Цвет колесика
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else if (snapshot.hasData) {
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: Colors.grey[850], // Темный цвет карточек
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    titleBuilder(item),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    subtitleBuilder(item),
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          print('Нажата кнопка редактирования для ID: ${item['id']}');
                          _showEditDialog(
                            context,
                            'Редактировать результат',
                            item,
                            editResult,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: Text('Нет данных.', style: TextStyle(color: Colors.white)));
        }
      },
    );
  }

  // Диалог для добавления результата
  void _showAddDialog(
      BuildContext context,
      String title,
      Map<String, dynamic> fields,
      Function(Map<String, dynamic>) onSave,
      ) {
    final controllers = fields.map((key, _) => MapEntry(key, TextEditingController()));
    int? selectedStudent;
    int? selectedSchool;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850], // Темный фон диалога
              title: Text(title, style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllers['score'],
                      decoration: InputDecoration(labelText: 'Оценка', labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: controllers['dateevent'],
                      decoration: InputDecoration(labelText: 'Дата', labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: controllers['subject'],
                      decoration: InputDecoration(labelText: 'Предмет', labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Выберите ученика',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: Supabase.instance.client
                          .from('students')
                          .select()
                          .then((value) => value as List<dynamic>),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        }
                        return DropdownButton<int>(
                          isExpanded: true,
                          value: selectedStudent,
                          hint: Text('Выберите ученика', style: TextStyle(color: Colors.white)),
                          dropdownColor: Colors.grey[850],
                          style: TextStyle(color: Colors.white),
                          items: snapshot.data!.map((student) {
                            return DropdownMenuItem<int>(
                              value: student['id'],
                              child: Text('${student['name']} ${student['surname']}', style: TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStudent = value;
                            });
                          },
                        );
                      },
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: Supabase.instance.client
                          .from('schools')
                          .select()
                          .then((value) => value as List<dynamic>),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        }
                        return DropdownButton<int>(
                          isExpanded: true,
                          value: selectedSchool,
                          hint: Text('Выберите школу', style: TextStyle(color: Colors.white)),
                          dropdownColor: Colors.grey[850],
                          style: TextStyle(color: Colors.white),
                          items: snapshot.data!.map((school) {
                            return DropdownMenuItem<int>(
                              value: school['id'],
                              child: Text('№${school['number']}', style: TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSchool = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    onSave({
                      'score': controllers['score']?.text,
                      'dateevent': controllers['dateevent']?.text,
                      'subject': controllers['subject']?.text,
                      'studentid': selectedStudent,
                      'numberschool': selectedSchool,
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Диалог для редактирования результата
  void _showEditDialog(
      BuildContext context,
      String title,
      Map<String, dynamic> result,
      Function(int, Map<String, dynamic>) onSave,
      ) {
    final controllers = {
      'score': TextEditingController(text: result['score'].toString()),
      'dateevent': TextEditingController(text: result['dateevent'].toString()),
      'subject': TextEditingController(text: result['subject'].toString()),
    };
    int? selectedStudent = result['studentid'];
    int? selectedSchool = result['numberschool'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850], // Темный фон диалога
              title: Text(title, style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllers['score'],
                      decoration: InputDecoration(labelText: 'Оценка', labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: controllers['dateevent'],
                      decoration: InputDecoration(labelText: 'Дата', labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: controllers['subject'],
                      decoration: InputDecoration(labelText: 'Предмет', labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Выберите ученика',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: Supabase.instance.client
                          .from('students')
                          .select()
                          .then((value) => value as List<dynamic>),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        }
                        return DropdownButton<int>(
                          isExpanded: true,
                          value: selectedStudent,
                          hint: Text('Выберите ученика', style: TextStyle(color: Colors.white)),
                          dropdownColor: Colors.grey[850],
                          style: TextStyle(color: Colors.white),
                          items: snapshot.data!.map((student) {
                            return DropdownMenuItem<int>(
                              value: student['id'],
                              child: Text('${student['name']} ${student['surname']}', style: TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStudent = value;
                            });
                          },
                        );
                      },
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: Supabase.instance.client
                          .from('schools')
                          .select()
                          .then((value) => value as List<dynamic>),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        }
                        return DropdownButton<int>(
                          isExpanded: true,
                          value: selectedSchool,
                          hint: Text('Выберите школу', style: TextStyle(color: Colors.white)),
                          dropdownColor: Colors.grey[850],
                          style: TextStyle(color: Colors.white),
                          items: snapshot.data!.map((school) {
                            return DropdownMenuItem<int>(
                              value: school['id'],
                              child: Text('№${school['number']}', style: TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSchool = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    onSave(result['id'], {
                      'score': controllers['score']?.text,
                      'dateevent': controllers['dateevent']?.text,
                      'subject': controllers['subject']?.text,
                      'studentid': selectedStudent,
                      'numberschool': selectedSchool,
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
