// models.dart
class Student {
  final String id;
  final String name;
  final int age;
  final String schoolId;

  Student({required this.id, required this.name, required this.age, required this.schoolId});

  // Метод для создания объекта из JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      schoolId: json['schoolId'],
    );
  }

  // Метод для преобразования в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'schoolId': schoolId,
    };
  }
}

class School {
  final String id;
  final String name;

  School({required this.id, required this.name});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Itog {
  final String studentId;
  final String schoolId;
  final String result;

  Itog({required this.studentId, required this.schoolId, required this.result});

  factory Itog.fromJson(Map<String, dynamic> json) {
    return Itog(
      studentId: json['studentId'],
      schoolId: json['schoolId'],
      result: json['result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'result': result,
    };
  }
}
