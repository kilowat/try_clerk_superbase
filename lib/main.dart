import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:try_clerk_superbase/repositories/api_database.dart';
import 'package:try_clerk_superbase/repositories/authentication.dart';
import 'package:try_clerk_superbase/repositories/supa_database.dart';
import 'package:try_clerk_superbase/services/clerk_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final clerkService = ClerkService();
  await clerkService.initialize();
  await Supabase.initialize(
    url: dotenv.get('SUPA_BASE_URL'),
    anonKey: dotenv.get('SUPA_BASE_ANON_KEY'),
    accessToken: clerkService.getTemplateToken,
  );

  runApp(MainApp(
    apiDatabaseRepository: SupabaseRepository(),
    authenticationRepository: AuthenticationRepository(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.apiDatabaseRepository,
    required this.authenticationRepository,
  });

  final ApiDatabaseRepository apiDatabaseRepository;
  final AuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
