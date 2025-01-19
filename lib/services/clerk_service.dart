import 'dart:convert';
import 'dart:io';
import 'package:clerk_auth/clerk_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClerkService {
  static late Api _api;
  late final String? _sessionId;
  static late final String? _publicKey;
  static late final Persistor _persistor;

  static Future<void> initialize({
    required String publishableKey,
    required String publicKey,
    Persistor? persistor,
  }) async {
    _persistor = persistor ?? const _Persistor();
    _api = Api(
      publishableKey: publishableKey,
      publicKey: publicKey,
      persistor: _persistor,
    );
    _publicKey = publicKey;

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
    final clerkClientToken =
        await _persistor.read('_clerkClientToken_${_publicKey.hashCode}');
    if (clerkClientToken == null) return '';

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
