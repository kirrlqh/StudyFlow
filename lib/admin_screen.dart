import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
Color myCustomColor = Color(0xFF42A5F5); // Яркий голубой
class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black, // Темный фон страницы
        appBar: AppBar(
          backgroundColor: Colors.grey[850], // Темный фон AppBar
          title: Text('Админ панель', style: TextStyle(color: Colors.white)), // Белый текст
          actions: [
            // Кнопка для возврата на страницу авторизации
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.white), // Белая иконка
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white, // Белый цвет текста для вкладок
            unselectedLabelColor: Colors.grey, // Серый цвет для невыбранных вкладок
            indicatorColor: Colors.blue, // Зеленая индикаторная линия
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
    return Scaffold(
      backgroundColor: Colors.black, // Темный фон страницы
      appBar: AppBar(
        title: Text('Ученики', style: TextStyle(color: Colors.white)), // Белый текст на AppBar
        backgroundColor: Colors.grey[900], // Темный AppBar
      ),
      body: FutureBuilder<List<dynamic>>(
        future: students,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Синий цвет загрузочного индикатора
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final studentList = snapshot.data!;
            return ListView.builder(
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                final student = studentList[index];
                return Card(
                  color: Colors.grey[850], // Темный фон карточки
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(
                      '${student['name']} ${student['surname']}',
                      style: TextStyle(color: Colors.white), // Белый текст
                    ),
                    subtitle: FutureBuilder<List<dynamic>>(
                      future: schools, // Используем schools, чтобы получить данные о школах
                      builder: (context, snapshot) {
                        String schoolNumber = 'Не найдено'; // Значение по умолчанию

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white));
                        } else if (snapshot.hasData) {
                          final schoolList = snapshot.data!;
                          final school = schoolList.firstWhere(
                                (school) => school['id'] == student['numberschool'],
                            orElse: () => {'number': 'Не найдено'},
                          );
                          schoolNumber = school['number'].toString();
                        }

                        return Text(
                          'Класс: ${student['class']} | Школа №$schoolNumber',
                          style: TextStyle(color: Colors.white70),
                        );
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue), // Синие кнопки редактирования
                          onPressed: () {
                            _showEditDialog(context, 'Редактировать ученика', student, editStudent);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red), // Красная кнопка удаления
                          onPressed: () => deleteStudent(student['id']),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showEditDialog(context, 'Редактировать ученика', student, editStudent);
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Нет данных.', style: TextStyle(color: Colors.white)));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(
          context,
          'Добавить ученика',
          {'name': '', 'surname': '', 'class': '', 'numberschool': ''},
          addStudent,
        ),
        backgroundColor: Colors.blueAccent, // Яркая кнопка добавления
        child: Icon(Icons.add, color: Colors.white), // Белый плюсик
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
    int? selectedSchool; // Хранит ID выбранной школы.

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850], // Темный фон диалога
              title: Text(title, style: TextStyle(color: Colors.white)), // Белый текст
              content: FutureBuilder<List<dynamic>>(
                future: schools,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white));
                  } else if (snapshot.hasData) {
                    final schoolList = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: controllers['name'],
                            decoration: InputDecoration(
                              labelText: 'Имя',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          TextField(
                            controller: controllers['surname'],
                            decoration: InputDecoration(
                              labelText: 'Фамилия',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          TextField(
                            controller: controllers['class'],
                            decoration: InputDecoration(
                              labelText: 'Класс',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          DropdownButton<int>(
                            isExpanded: true,
                            hint: Text('Выберите школу', style: TextStyle(color: Colors.white)),
                            value: selectedSchool,
                            items: schoolList.map((school) {
                              return DropdownMenuItem<int>(
                                value: school['id'],
                                child: Text('Школа №${school['number']}', style: TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                selectedSchool = value;
                              });
                            },
                            dropdownColor: Colors.grey[850], // Темный фон для выпадающего списка
                            style: TextStyle(color: Colors.white), // Белый текст в списке
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('Нет данных.', style: TextStyle(color: Colors.white));
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
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
                  child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
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
    int? selectedSchool = item['numberschool']; // ID школы для редактируемого ученика

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850], // Темный фон диалога
              title: Text(title, style: TextStyle(color: Colors.white)),
              content: FutureBuilder<List<dynamic>>(
                future: schools,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white));
                  } else if (snapshot.hasData) {
                    final schoolList = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: controllers['name'],
                            decoration: InputDecoration(
                              labelText: 'Имя',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          TextField(
                            controller: controllers['surname'],
                            decoration: InputDecoration(
                              labelText: 'Фамилия',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          TextField(
                            controller: controllers['class'],
                            decoration: InputDecoration(
                              labelText: 'Класс',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          DropdownButton<int>(
                            isExpanded: true,
                            value: selectedSchool,
                            items: schoolList.map((school) {
                              return DropdownMenuItem<int>(
                                value: school['id'],
                                child: Text('Школа №${school['number']}', style: TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                selectedSchool = value;
                              });
                            },
                            dropdownColor: Colors.grey[850], // Темный фон для выпадающего списка
                            style: TextStyle(color: Colors.white), // Белый текст в списке
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('Нет данных.', style: TextStyle(color: Colors.white));
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    final data = controllers.map((key, controller) => MapEntry(key, controller.text));

                    if (selectedSchool != null) {
                      data['numberschool'] = selectedSchool.toString();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Выберите школу')),
                      );
                      return;
                    }

                    onSave(item['id'], data); // Отправляем изменения для редактирования
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
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
  late Future<List<dynamic>> students;
  late Future<List<dynamic>> schools;

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

  Future<List<dynamic>> fetchStudents() async {
    final response = await Supabase.instance.client
        .from('students')
        .select('id, name, surname')
        .then((value) => value as List<dynamic>);
    return response;
  }

  Future<List<dynamic>> fetchSchools() async {
    final response = await Supabase.instance.client
        .from('schools')
        .select('id, number')
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
    students = fetchStudents();
    schools = fetchSchools();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Результаты', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: results,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final resultList = snapshot.data!;
            return ListView.builder(
              itemCount: resultList.length,
              itemBuilder: (context, index) {
                final result = resultList[index];
                return Card(
                  color: Colors.grey[850],
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(
                      'Результат: ${result['score']} | Ученик: ${result['student']['name']} ${result['student']['surname']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Дата: ${result['dateevent']} | Предмет: ${result['subject']} | Школа №${result['numberschool']['number']}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditDialog(context, 'Редактировать результат', result, editResult);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteResult(result['id']),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showEditDialog(context, 'Редактировать результат', result, editResult);
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Нет данных.', style: TextStyle(color: Colors.white)));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(
          context,
          'Добавить результат',
          {'score': '', 'dateevent': '', 'subject': '', 'studentid': '', 'numberschool': ''},
          addResult,
        ),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title: Text(title, style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllers['score'],
                      decoration: InputDecoration(
                        labelText: 'Результат',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue,
                    ),
                    TextField(
                      controller: controllers['dateevent'],
                      decoration: InputDecoration(
                        labelText: 'Дата события',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue,
                    ),
                    TextField(
                      controller: controllers['subject'],
                      decoration: InputDecoration(
                        labelText: 'Предмет',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue,
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: students,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Ошибка: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final studentList = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Выберите ученика',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            dropdownColor: Colors.grey[850],
                            items: studentList.map((student) {
                              return DropdownMenuItem<String>(
                                value: student['id'].toString(),
                                child: Text('${student['name']} ${student['surname']}', style: TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controllers['studentid']?.text = value!;
                            },
                          );
                        } else {
                          return Center(child: Text('Нет данных.'));
                        }
                      },
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: schools,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Ошибка: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final schoolList = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Выберите школу',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            dropdownColor: Colors.grey[850],
                            items: schoolList.map((school) {
                              return DropdownMenuItem<String>(
                                value: school['id'].toString(),
                                child: Text('Школа №${school['number']}', style: TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controllers['numberschool']?.text = value!;
                            },
                          );
                        } else {
                          return Center(child: Text('Нет данных.'));
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    final data = controllers.map((key, controller) => MapEntry(key, controller.text));

                    // Вызываем сохранение
                    onSave(data);

                    // Закрываем диалог
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
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
      'studentid': TextEditingController(text: item['student']?['id']?.toString() ?? ''),
      'numberschool': TextEditingController(text: item['numberschool']?['id']?.toString() ?? ''),
    };

    String? selectedStudentId = item['student']?['id']?.toString();
    String? selectedSchoolId = item['numberschool']?['id']?.toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title: Text(title, style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllers['score'],
                      decoration: InputDecoration(
                        labelText: 'Результат',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue,
                    ),
                    TextField(
                      controller: controllers['dateevent'],
                      decoration: InputDecoration(
                        labelText: 'Дата события',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue,
                    ),
                    TextField(
                      controller: controllers['subject'],
                      decoration: InputDecoration(
                        labelText: 'Предмет',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue,
                    ),
                    // Выбор ученика
                    FutureBuilder<List<dynamic>>(
                      future: students,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Ошибка: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final studentList = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Выберите ученика',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            value: selectedStudentId, // Устанавливаем значение выбранного ученика
                            dropdownColor: Colors.grey[850],
                            items: studentList.map((student) {
                              return DropdownMenuItem<String>(
                                value: student['id'].toString(),
                                child: Text('${student['name']} ${student['surname']}', style: TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStudentId = value!;
                                controllers['studentid']?.text = value;
                              });
                            },
                          );
                        } else {
                          return Center(child: Text('Нет данных.'));
                        }
                      },
                    ),
                    // Выбор школы
                    FutureBuilder<List<dynamic>>(
                      future: schools,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Ошибка: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final schoolList = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Выберите школу',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            value: selectedSchoolId, // Устанавливаем значение выбранной школы
                            dropdownColor: Colors.grey[850],
                            items: schoolList.map((school) {
                              return DropdownMenuItem<String>(
                                value: school['id'].toString(),
                                child: Text('Школа №${school['number']}', style: TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSchoolId = value!;
                                controllers['numberschool']?.text = value;
                              });
                            },
                          );
                        } else {
                          return Center(child: Text('Нет данных.'));
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    final data = controllers.map((key, controller) => MapEntry(key, controller.text));

                    // Добавляем выбранных ученика и школу в данные
                    data['studentid'] = selectedStudentId!;
                    data['numberschool'] = selectedSchoolId!;

                    // Вызываем сохранение
                    onSave(item['id'], data);

                    // Закрываем диалог
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
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
    return Scaffold(
      backgroundColor: Colors.black, // Темный фон страницы
      appBar: AppBar(
        title: Text('Школы', style: TextStyle(color: Colors.white)), // Белый текст
        backgroundColor: Colors.grey[900], // Черный AppBar
        iconTheme: IconThemeData(color: Colors.white), // Белые иконки
      ),
      body: FutureBuilder<List<dynamic>>(
        future: schools,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Синий цвет загрузочного индикатора
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final schoolList = snapshot.data!;
            return ListView.builder(
              itemCount: schoolList.length,
              itemBuilder: (context, index) {
                final school = schoolList[index];
                return Card(
                  color: Colors.grey[800], // Темный фон карточки
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(
                      'Школа №${school['number']}',
                      style: TextStyle(color: Colors.white), // Белый текст
                    ),
                    subtitle: Text(
                      'Адрес: ${school['address']}',
                      style: TextStyle(color: Colors.white70), // Белый с прозрачным
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Ограничивает ширину
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue), // Иконка редактирования
                          onPressed: () {
                            _showEditDialog(context, 'Редактировать школу', school, editSchool);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red), // Красная иконка удаления
                          onPressed: () => deleteSchool(school['id']),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showEditDialog(context, 'Редактировать школу', school, editSchool);
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Нет данных.', style: TextStyle(color: Colors.white)));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(
          context,
          'Добавить школу',
          {'number': '', 'address': ''},
          addSchool,
        ),
        backgroundColor: Colors.blueAccent, // Синий цвет кнопки
        child: Icon(Icons.add, color: Colors.white), // Белый плюсик
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[800], // Темный фон диалога
              title: Text(title, style: TextStyle(color: Colors.white)), // Белый текст
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllers['number'],
                      decoration: InputDecoration(
                        labelText: 'Номер школы',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue), // Синий цвет для фокуса
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue, // Синий цвет для курсора
                    ),
                    TextField(
                      controller: controllers['address'],
                      decoration: InputDecoration(
                        labelText: 'Адрес школы',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue), // Синий цвет для фокуса
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue, // Синий цвет для курсора
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    final data = controllers.map((key, controller) => MapEntry(key, controller.text));

                    // Вызываем сохранение
                    onSave(data);

                    // Закрываем диалог
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
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
      'number': TextEditingController(text: item['number'].toString()),
      'address': TextEditingController(text: item['address']),
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[800], // Темный фон диалога
              title: Text(title, style: TextStyle(color: Colors.white)), // Белый текст
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllers['number'],
                      decoration: InputDecoration(
                        labelText: 'Номер школы',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue), // Синий цвет для фокуса
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue, // Синий цвет для курсора
                    ),
                    TextField(
                      controller: controllers['address'],
                      decoration: InputDecoration(
                        labelText: 'Адрес школы',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue), // Синий цвет для фокуса
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.blue, // Синий цвет для курсора
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    final data = controllers.map((key, controller) => MapEntry(key, controller.text));

                    // Вызываем сохранение
                    onSave(item['id'], data);

                    // Закрываем диалог
                    Navigator.pop(context);
                  },
                  child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
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
    backgroundColor: Colors.grey[900], // Темный фон страницы
    body: FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else if (snapshot.hasData) {
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: Colors.grey[800], // Темный фон карточки
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    titleBuilder(item),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), // Белый текст
                  ),
                  subtitle: Text(
                    subtitleBuilder(item),
                    style: TextStyle(color: Colors.white70), // Белый с прозрачным
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => onEdit(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
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
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: onAdd,
      child: Icon(Icons.add),
      backgroundColor: Colors.greenAccent, // Яркий зеленый для кнопки добавления
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
        backgroundColor: Colors.grey[800], // Темный фон диалога
        title: Text(title, style: TextStyle(color: Colors.white)), // Белый текст
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fields.keys.map((key) {
            return TextField(
              controller: controllers[key],
              decoration: InputDecoration(
                labelText: key,
                labelStyle: TextStyle(color: Colors.white), // Белая метка
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
              ),
              style: TextStyle(color: Colors.white), // Белый текст
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              final data = controllers.map((key, controller) => MapEntry(key, controller.text));
              onSave(data);
              Navigator.pop(context);
            },
            child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
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
        backgroundColor: Colors.grey[800], // Темный фон диалога
        title: Text(title, style: TextStyle(color: Colors.white)), // Белый текст
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: item.keys.map((key) {
            return TextField(
              controller: controllers[key],
              decoration: InputDecoration(
                labelText: key,
                labelStyle: TextStyle(color: Colors.white), // Белая метка
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
              ),
              style: TextStyle(color: Colors.white), // Белый текст
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              final data = controllers.map((key, controller) => MapEntry(key, controller.text));
              onSave(item['id'], data);
              Navigator.pop(context);
            },
            child: Text('Сохранить', style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}

/// ------------------- Обновления для выпадающих списков -------------------

Widget _buildDropdownButton(
    {required String label,
      required String value,
      required List<String> options,
      required Function(String) onChanged}) {
  return DropdownButtonFormField<String>(
    value: value,
    onChanged: (newValue) => onChanged(newValue!),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white), // Белая метка
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)), // Синий бордер при фокусе
    ),
    dropdownColor: Colors.grey[850], // Темный фон выпадающего списка
    style: TextStyle(color: Colors.white), // Белый текст в списке
    items: options
        .map((option) => DropdownMenuItem<String>(
      value: option,
      child: Text(option),
    ))
        .toList(),
  );
}



