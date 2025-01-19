import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart';
import 'package:http/http.dart' as http;

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  final clerkApi = Api(
    publishableKey: dotenv.get('CLERK_PUBLISHABLE_KEY'),
    publicKey: dotenv.get('CLERK_PUBLIC_KEY'),
    persistor: _Persistor(),
  );

  await clerkApi.initialize();
  await clerkApi.signOut();
  final response =
      await clerkApi.createSignIn(identifier: dotenv.get('USER_ID'));
  final signIn = response.client!.signIn!;
  final attemptResponse = await clerkApi.attemptSignIn(
    signIn,
    stage: Stage.first,
    strategy: Strategy.password,
    password: dotenv.get('USER_PASS'),
  );

  // final templateToken = await api.getTokenWithTemplate('supabase', sessionId);
  getAccestoken() async {
    final prefs = await SharedPreferences.getInstance();
    final publicKeyHash = dotenv.get('CLERK_PUBLIC_KEY').hashCode;
    final clerkClientToken =
        prefs.getString('_clerkClientToken_$publicKeyHash');
    final sessionId = attemptResponse.client!.sessionIds.first;
    const templateName = 'supabase';
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      HttpHeaders.authorizationHeader: clerkClientToken!,
    };

    final url = Uri.https('neat-bull-18.clerk.accounts.dev',
        'v1/client/sessions/$sessionId/tokens/$templateName');
    final res = await http.post(
      url,
      headers: headers,
    );
    final supaBaseJwtToken = jsonDecode(res.body)['jwt'] as String;

    return supaBaseJwtToken;
  }

  await Supabase.initialize(
    url: dotenv.get('SUPA_BASE_URL'),
    anonKey: dotenv.get('SUPA_BASE_ANON_KEY'),
    accessToken: getAccestoken,
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

/*
Future<String> getTokenWithTemplate(String templateName, sessionId) async {
  final url = '/client/sessions/${sessionId}/tokens/$templateName';

  final resp = await _fetch(
    path: url,
    headers: _headers(HttpMethod.post),
    method: HttpMethod.post,
  );

  if (resp.statusCode == HttpStatus.ok) {
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return body['jwt'] as String;
  }

  throw Exception('Failed to get template token: ${resp.statusCode}');
}
*/
class _Persistor implements Persistor {
  const _Persistor();

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
