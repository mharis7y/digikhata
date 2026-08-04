import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ezpqcdologgpvprsdlek.supabase.co',
    publishableKey: 'sb_publishable_Gtsfk1aXjfe5C9OTObiC7g_-mwx5xB-',
  );

  runApp(const App());
}
