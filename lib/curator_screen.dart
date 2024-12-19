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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Переходим на экран авторизации
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<dynamic>>(
            future: results,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Ошибка: ${snapshot.error}',
                      style: TextStyle(color: Colors.white)),
                );
              } else if (snapshot.hasData) {
                final resultList = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 80),
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
                return Center(
                  child: Text('Нет данных.', style: TextStyle(color: Colors.white)),
                );
              }
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _showAddDialog(
                context,
                'Добавить результат',
                {
                  'score': '',
                  'dateevent': '',
                  'subject': '',
                  'studentid': '',
                  'numberschool': ''
                },
                addResult,
              ),
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    final result = {
                      'score': controllers['score']?.text ?? '',
                      'dateevent': controllers['dateevent']?.text ?? '',
                      'subject': controllers['subject']?.text ?? '',
                      'studentid': controllers['studentid']?.text ?? '',
                      'numberschool': controllers['numberschool']?.text ?? '',
                    };
                    onSave(result);
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

  void _showEditDialog(BuildContext context, String title, dynamic result, Function(int, Map<String, dynamic>) onEdit) {
    final controllers = {
      'score': TextEditingController(text: result['score'].toString()),
      'dateevent': TextEditingController(text: result['dateevent']),
      'subject': TextEditingController(text: result['subject']),
      'studentid': TextEditingController(text: result['student']['id'].toString()),
      'numberschool': TextEditingController(text: result['numberschool']['id'].toString()),
    };

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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    final editedResult = {
                      'score': controllers['score']?.text ?? '',
                      'dateevent': controllers['dateevent']?.text ?? '',
                      'subject': controllers['subject']?.text ?? '',
                      'studentid': controllers['studentid']?.text ?? '',
                      'numberschool': controllers['numberschool']?.text ?? '',
                    };
                    onEdit(result['id'], editedResult);
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
