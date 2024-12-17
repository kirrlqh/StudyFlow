import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  final String baseUrl = "https://example.com/api";  // Укажите ваш URL API

  // Получить список студентов
  Future<List<Student>> getStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/students'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((studentJson) => Student.fromJson(studentJson)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  // Получить список школ
  Future<List<School>> getSchools() async {
    final response = await http.get(Uri.parse('$baseUrl/schools'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((schoolJson) => School.fromJson(schoolJson)).toList();
    } else {
      throw Exception('Failed to load schools');
    }
  }

  // Получить итоговые данные
  Future<List<Itog>> getItogs() async {
    final response = await http.get(Uri.parse('$baseUrl/itogs'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((itogJson) => Itog.fromJson(itogJson)).toList();
    } else {
      throw Exception('Failed to load itogs');
    }
  }
}
