import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://tfjcgrqanaebmvlenkmk.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmamNncnFhbmFlYm12bGVua21rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE5MjU4ODEsImV4cCI6MjA0NzUwMTg4MX0.tiOywO7Wg2deTx_YUdofkUGiADXFVf2ieReJJn8W5mE';

  // Инициализация Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
