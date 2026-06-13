import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
    } catch (e) {
      throw 'Failed to initialize Supabase: $e';
    }
  }

  // Get Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw 'Supabase not initialized. Call SupabaseService.initialize() first.';
    }
    return _client!;
  }

  // Check if initialized
  static bool get isInitialized => _client != null;
}
