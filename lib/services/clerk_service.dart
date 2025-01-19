import 'dart:convert';
import 'dart:io';
import 'package:clerk_auth/clerk_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClerkService {
  ClerkService({Api? api})
      : _api = api ??
            Api(
              publishableKey: dotenv.get('CLERK_PUBLISHABLE_KEY'),
              publicKey: dotenv.get('CLERK_PUBLIC_KEY'),
              persistor: const _Persistor(),
            );
  final Api _api;

  late final String? _sessionId;

  Future<void> initialize() async {
    await _api.initialize();
  }

  signin() async {
    final response = await _api.createSignIn(identifier: dotenv.get('USER_ID'));
    final signIn = response.client!.signIn!;
    final attemptResponse = await _api.attemptSignIn(
      signIn,
      stage: Stage.first,
      strategy: Strategy.password,
      password: dotenv.get('USER_PASS'),
    );

    _sessionId = attemptResponse.client?.sessionIds.first;
  }

  Future<String> getTemplateToken({String template = 'supabase'}) async {
    final prefs = await SharedPreferences.getInstance();
    final publicKeyHash = dotenv.get('CLERK_PUBLIC_KEY').hashCode;
    final clerkClientToken =
        prefs.getString('_clerkClientToken_$publicKeyHash')!;

    final url = Uri.https(
      'neat-bull-18.clerk.accounts.dev',
      'v1/client/sessions/$_sessionId/tokens/$template',
    );

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: clerkClientToken,
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    return jsonDecode(response.body)['jwt'] as String;
  }
}

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
