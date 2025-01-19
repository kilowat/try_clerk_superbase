import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart';
import 'package:http/http.dart' as http;
import 'package:try_clerk_superbase/services/clerk_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  final clerkService = ClerkService();
  await clerkService.initialize();
  await Supabase.initialize(
    url: dotenv.get('SUPA_BASE_URL'),
    anonKey: dotenv.get('SUPA_BASE_ANON_KEY'),
    //accessToken: getAccestoken,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
