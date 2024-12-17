import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CuratorScreen extends StatefulWidget {
  @override
  _CuratorScreenState createState() => _CuratorScreenState();
}

class _CuratorScreenState extends State<CuratorScreen> {
  List<Map<String, dynamic>> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  // Загрузка данных из таблицы results
  Future<void> fetchResults() async {
    try {
      final response = await Supabase.instance.client
          .from('results')
          .select(); // Запрос данных из таблицы

      if (response is List) {
        setState(() {
          results = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else {
        setState(() {
          results = [];
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Куратор - Результаты'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : results.isEmpty
          ? Center(child: Text('Нет данных для отображения'))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Student ID')),
            DataColumn(label: Text('Score')),
            DataColumn(label: Text('School #')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Subject')),
          ],
          rows: results.map((result) {
            return DataRow(
              cells: [
                DataCell(Text(result['id']?.toString() ?? '—')),
                DataCell(Text(result['studentid']?.toString() ?? '—')),
                DataCell(Text(result['score']?.toString() ?? '—')),
                DataCell(Text(result['numberschool']?.toString() ?? '—')),
                DataCell(Text(result['dateevent'] ?? '—')),
                DataCell(Text(result['subject'] ?? '—')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
