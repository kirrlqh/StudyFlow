import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static late SupabaseClient client;

  // Метод для инициализации Supabase
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://tfjcgrqanaebmvlenkmk.supabase.co',  // URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmamNncnFhbmFlYm12bGVua21rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE5MjU4ODEsImV4cCI6MjA0NzUwMTg4MX0.tiOywO7Wg2deTx_YUdofkUGiADXFVf2ieReJJn8W5mE',  // anon key
    );
    client = Supabase.instance.client;
  }
}
