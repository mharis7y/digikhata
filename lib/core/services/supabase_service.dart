import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase architectural service wrapper for DigiKhata Clone per agents.md.
/// Handles authentication, database queries, and realtime subscriptions.
class SupabaseService {
  SupabaseService._();

  static const String supabaseUrl = 'https://ezpqcdologgpvprsdlek.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_Gtsfk1aXjfe5C9OTObiC7g_-mwx5xB-';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static SupabaseStorageClient get storage => client.storage;
}
