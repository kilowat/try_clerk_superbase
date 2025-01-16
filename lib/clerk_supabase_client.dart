import 'package:supabase_flutter/supabase_flutter.dart';

class ClerkSupabaseClient {
  static ClerkSupabaseClient? _instance;
  final SupabaseClient _supabaseClient;

  ClerkSupabaseClient._({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  static Future<ClerkSupabaseClient> initialize(
    String url,
    String anonKey,
    Future<String> Function() getToken,
  ) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    if (_instance != null) return _instance!;

    final supabaseClient = await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    _instance = ClerkSupabaseClient._(
      supabaseClient: supabaseClient.client,
    );

    return _instance!;
  }

  SupabaseQueryBuilder from(String table) => _supabaseClient.from(table);
  GoTrueClient get auth => _supabaseClient.auth;
  SupabaseStorageClient get storage => _supabaseClient.storage;

  static void dispose() {
    _instance?._supabaseClient.dispose();
    _instance = null;
  }
}
