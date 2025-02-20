import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:try_clerk_superbase/import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await ClerkService.initialize(
    publishableKey: dotenv.get('CLERK_PUBLISHABLE_KEY'),
    publicKey: dotenv.get('CLERK_PUBLIC_KEY'),
  );

  await SupabseService.initialize(
    url: dotenv.get('SUPA_BASE_URL'),
    anonKey: dotenv.get('SUPA_BASE_ANON_KEY'),
    accessToken: ClerkService.getTemplateToken,
  );
  final authenticationRepository = AuthenticationRepository();
  //await authenticationRepository.logout();
  await authenticationRepository.authorize();
  final apiDatabaseRepository = SupabaseRepository();
  final todos = await apiDatabaseRepository.readTodos();

  runApp(MainApp(
    apiDatabaseRepository: apiDatabaseRepository,
    authenticationRepository: authenticationRepository,
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
