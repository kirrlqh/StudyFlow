import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Админ панель'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Ученики'),
              Tab(text: 'Результаты'),
              Tab(text: 'Школы'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StudentsTab(),
            ResultsTab(),
            SchoolsTab(),
          ],
        ),
      ),
    );
  }
}

/// ------------------- Вкладка "Ученики" -------------------
class StudentsTab extends StatefulWidget {
  @override
  _StudentsTabState createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  late Future<List<dynamic>> students;
  late Future<List<dynamic>> schools;

  Future<List<dynamic>> fetchStudents() async {
    final response = await Supabase.instance.client
        .from('students')
        .select()
        .then((value) => value as List<dynamic>);
    return response;
  }

  Future<List<dynamic>> fetchSchools() async {
    final response = await Supabase.instance.client
        .from('schools')
        .select()
        .then((value) => value as List<dynamic>);
    return response;
  }

  Future<void> deleteStudent(int id) async {
    await Supabase.instance.client.from('students').delete().eq('id', id);
    setState(() {
      students = fetchStudents();
    });
  }

  Future<void> addStudent(Map<String, dynamic> student) async {
    await Supabase.instance.client.from('students').insert(student);
    setState(() {
      students = fetchStudents();
    });
  }

  Future<void> editStudent(int id, Map<String, dynamic> student) async {
    await Supabase.instance.client.from('students').update(student).eq('id', id);
    setState(() {
      students = fetchStudents();
    });
  }

  @override
  void initState() {
    super.initState();
    students = fetchStudents();
    schools = fetchSchools();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTab(
      context,
      students,
          (item) => '${item['name']} ${item['surname']}',
          (item) => 'Класс: ${item['class']}, Школа: ${item['numberschool']}',
          () => _showAddDialog(
        context,
        'Добавить ученика',
        {'name': '', 'surname': '', 'class': '', 'numberschool': ''},
        addStudent,
      ),
          (item) => _showEditDialog(
        context,
        'Редактировать ученика',
        item,
        editStudent,
      ),
      deleteStudent,
    );
  }

  void _showAddDialog(
      BuildContext context,
      String title,
      Map<String, dynamic> fields,
      Function(Map<String, dynamic>) onSave,
      ) {
    final controllers = fields.map((key, _) => MapEntry(key, TextEditingController()));
    int? selectedSchool; // Хранит ID выбранной школы.

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: FutureBuilder<List<dynamic>>(
                future: schools,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Ошибка: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final schoolList = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: controllers['name'],
                            decoration: InputDecoration(labelText: 'Имя'),
                          ),
                          TextField(
                            controller: controllers['surname'],
                            decoration: InputDecoration(labelText: 'Фамилия'),
                          ),
                          TextField(
                            controller: controllers['class'],
                            decoration: InputDecoration(labelText: 'Класс'),
                          ),
                          DropdownButton<int>(
                            isExpanded: true,
                            hint: Text('Выберите школу'),
                            value: selectedSchool,
                            items: schoolList.map((school) {
                              return DropdownMenuItem<int>(
                                value: school['id'],
                                child: Text('Школа №${school['number']}'),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                selectedSchool = value;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('Нет данных.');
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    final data = controllers.map((key, controller) => MapEntry(key, controller.text));

                    // Проверяем, выбрана ли школа
                    if (selectedSchool != null) {
                      data['numberschool'] = selectedSchool.toString();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Выберите школу')),
                      );
                      return;
                    }

                    // Вызываем сохранение
                    onSave(data);

                    // Закрываем диалог
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

  void _showEditDialog(
      BuildContext context,
      String title,
      Map<String, dynamic> item,
      Function(int, Map<String, dynamic>) onSave,
      ) {
    final controllers = {
      'name': TextEditingController(text: item['name']),
      'surname': TextEditingController(text: item['surname']),
      'class': TextEditingController(text: item['class']),
    };
    int? selectedSchool = item['numberschool']; // ID школы для редактирования.

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: FutureBuilder<List<dynamic>>(
                future: schools,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Ошибка: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final schoolList = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: controllers['name'],
                            decoration: InputDecoration(labelText: 'Имя'),
                          ),
                          TextField(
                            controller: controllers['surname'],
                            decoration: InputDecoration(labelText: 'Фамилия'),
                          ),
                          TextField(
                            controller: controllers['class'],
                            decoration: InputDecoration(labelText: 'Класс'),
                          ),
                          DropdownButton<int>(
                            isExpanded: true,
                            value: selectedSchool,
                            items: schoolList.map((school) {
                              return DropdownMenuItem<int>(
                                value: school['id'],
                                child: Text('Школа №${school['number']}'),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                selectedSchool = value;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('Нет данных.');
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    final data = controllers.map((key, controller) => MapEntry(key, controller.text));

                    // Проверяем, выбрана ли школа
                    if (selectedSchool != null) {
                      data['numberschool'] = selectedSchool.toString();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Выберите школу')),
                      );
                      return;
                    }

                    // Вызываем сохранение
                    onSave(item['id'], data);

                    // Закрываем диалог
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



/// ------------------- Вкладка "Результаты" -------------------
class ResultsTab extends StatefulWidget {
  @override
  _ResultsTabState createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
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
                    onSave(data);
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
                    onSave(item['id'], data);
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


/// ------------------- Вкладка "Школы" -------------------
class SchoolsTab extends StatefulWidget {
  @override
  _SchoolsTabState createState() => _SchoolsTabState();
}

class _SchoolsTabState extends State<SchoolsTab> {
  late Future<List<dynamic>> schools;

  Future<List<dynamic>> fetchSchools() async {
    final response = await Supabase.instance.client
        .from('schools')
        .select()
        .then((value) => value as List<dynamic>);
    return response;
  }

  Future<void> deleteSchool(int id) async {
    await Supabase.instance.client.from('schools').delete().eq('id', id);
    setState(() {
      schools = fetchSchools();
    });
  }

  Future<void> addSchool(Map<String, dynamic> school) async {
    await Supabase.instance.client.from('schools').insert(school);
    setState(() {
      schools = fetchSchools();
    });
  }

  Future<void> editSchool(int id, Map<String, dynamic> school) async {
    await Supabase.instance.client.from('schools').update(school).eq('id', id);
    setState(() {
      schools = fetchSchools();
    });
  }

  @override
  void initState() {
    super.initState();
    schools = fetchSchools();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTab(
      context,
      schools,
          (item) => 'Школа №${item['number']}',
          (item) => 'Адрес: ${item['address']}',
          () => _showAddDialog(
        context,
        'Добавить школу',
        {'number': '', 'address': ''},
        addSchool,
      ),
          (item) => _showEditDialog(
        context,
        'Редактировать школу',
        item,
        editSchool,
      ),
      deleteSchool,
    );
  }
}

/// ------------------- Общие виджеты -------------------
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

void _showAddDialog(
    BuildContext context,
    String title,
    Map<String, dynamic> fields,
    Function(Map<String, dynamic>) onSave,
    ) {
  final controllers = fields.map((key, _) => MapEntry(key, TextEditingController()));
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fields.keys.map((key) {
            return TextField(
              controller: controllers[key],
              decoration: InputDecoration(labelText: key),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final data = controllers.map((key, controller) => MapEntry(key, controller.text));
              onSave(data);
              Navigator.pop(context);
            },
            child: Text('Сохранить'),
          ),
        ],
      );
    },
  );
}

void _showEditDialog(
    BuildContext context,
    String title,
    Map<String, dynamic> item,
    Function(int, Map<String, dynamic>) onSave,
    ) {
  final controllers = item.map((key, value) => MapEntry(key, TextEditingController(text: value.toString())));
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: item.keys.map((key) {
            return TextField(
              controller: controllers[key],
              decoration: InputDecoration(labelText: key),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final data = controllers.map((key, controller) => MapEntry(key, controller.text));
              onSave(item['id'], data);
              Navigator.pop(context);
            },
            child: Text('Сохранить'),
          ),
        ],
      );
    },
  );
}