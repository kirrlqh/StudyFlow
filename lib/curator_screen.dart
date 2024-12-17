import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ------------------- Экран "Куратор" -------------------
class CuratorScreen extends StatefulWidget {
  @override
  _ResultsTabState createState() => _ResultsTabState();
}

class _ResultsTabState extends State<CuratorScreen> {
  late Future<List<dynamic>> results;

  Future<List<dynamic>> fetchResults() async {
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
    return _buildTab(
      context,
      results,
          (item) =>
      'Результат: ${item['score']} | Ученик: ${item['student']['name']} ${item['student']['surname']}',
          (item) =>
      'Дата: ${item['dateevent']} | Предмет: ${item['subject']} | Школа: ${item['numberschool']['number']}',
          () => _showAddDialog(
        context,
        'Добавить результат',
        {'score': '', 'dateevent': '', 'subject': ''},
        addResult,
      ),
          (item) => _showEditDialog(
        context,
        'Редактировать результат',
        item,
        editResult,
      ),
      deleteResult,
    );
  }

  // Общий виджет для отображения таба
  Widget _buildTab(
      BuildContext context,
      Future<List<dynamic>> future,
      String Function(Map<String, dynamic>) titleBuilder,
      String Function(Map<String, dynamic>) subtitleBuilder,
      VoidCallback onAdd,
      void Function(Map<String, dynamic>) onEdit,
      void Function(int) onDelete,
      ) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(titleBuilder(item)),
                  subtitle: Text(subtitleBuilder(item)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => onEdit(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => onDelete(item['id']),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Нет данных.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        child: Icon(Icons.add),
      ),
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
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllers['score'],
                      decoration: InputDecoration(labelText: 'Оценка'),
                    ),
                    TextField(
                      controller: controllers['dateevent'],
                      decoration: InputDecoration(labelText: 'Дата'),
                    ),
                    TextField(
                      controller: controllers['subject'],
                      decoration: InputDecoration(labelText: 'Предмет'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Выберите ученика',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: Supabase.instance.client
                          .from('students')
                          .select()
                          .then((value) => value as List<dynamic>),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        return DropdownButton<int>(
                          isExpanded: true,
                          value: selectedStudent,
                          hint: Text('Выберите ученика'),
                          items: snapshot.data!.map((student) {
                            return DropdownMenuItem<int>(
                              value: student['id'],
                              child: Text('${student['name']} ${student['surname']}'),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Выберите школу',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: Supabase.instance.client
                          .from('schools')
                          .select()
                          .then((value) => value as List<dynamic>),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        return DropdownButton<int>(
                          isExpanded: true,
                          value: selectedSchool,
                          hint: Text('Выберите школу'),
                          items: snapshot.data!.map((school) {
                            return DropdownMenuItem<int>(
                              value: school['id'],
                              child: Text('Школа №${school['number']}'),
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
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    final data = {
                      'score': controllers['score']!.text,
                      'dateevent': controllers['dateevent']!.text,
                      'subject': controllers['subject']!.text,
                      'studentid': selectedStudent,
                      'numberschool': selectedSchool,
                    };
                    onSave(data); // Передаем данные в функцию onSave (addResult)
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить'),
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
      Map<String, dynamic> item,
      Function(int, Map<String, dynamic>) onSave,
      ) {
    final controllers = {
      'score': TextEditingController(text: item['score'].toString()),
      'dateevent': TextEditingController(text: item['dateevent']),
      'subject': TextEditingController(text: item['subject']),
    };
    int? selectedStudent = item['student']['id'];
    int? selectedSchool = item['numberschool']['id'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllers['score'],
                      decoration: InputDecoration(labelText: 'Оценка'),
                    ),
                    TextField(
                      controller: controllers['dateevent'],
                      decoration: InputDecoration(labelText: 'Дата'),
                    ),
                    TextField(
                      controller: controllers['subject'],
                      decoration: InputDecoration(labelText: 'Предмет'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Выберите ученика',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: Supabase.instance.client
                          .from('students')
                          .select()
                          .then((value) => value as List<dynamic>),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        return DropdownButton<int>(
                          isExpanded: true,
                          value: selectedStudent,
                          items: snapshot.data!.map((student) {
                            return DropdownMenuItem<int>(
                              value: student['id'],
                              child: Text('${student['name']} ${student['surname']}'),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Выберите школу',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: Supabase.instance.client
                          .from('schools')
                          .select()
                          .then((value) => value as List<dynamic>),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        return DropdownButton<int>(
                          isExpanded: true,
                          value: selectedSchool,
                          items: snapshot.data!.map((school) {
                            return DropdownMenuItem<int>(
                              value: school['id'],
                              child: Text('Школа №${school['number']}'),
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
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    final data = {
                      'score': controllers['score']!.text,
                      'dateevent': controllers['dateevent']!.text,
                      'subject': controllers['subject']!.text,
                      'studentid': selectedStudent,
                      'numberschool': selectedSchool,
                    };
                    onSave(item['id'], data); // Передаем данные в функцию onSave (editResult)
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
