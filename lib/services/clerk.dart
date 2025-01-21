import 'dart:convert';
import 'dart:io';
import 'package:clerk_auth/clerk_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClerkService {
  static late Api _api;
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

  Future<User?> profile() async {
    final client = await _api.currentClient();
    return client.user;
  }

  Future<Client> signOut() async {
    return await _api.signOut();
  }

  Future<ApiResponse> signIn() async {
    final response = await _api.createSignIn(identifier: dotenv.get('USER_ID'));
    final signIn = response.client!.signIn!;
    final attemptResponse = await _api.attemptSignIn(
      signIn,
      stage: Stage.first,
      strategy: Strategy.password,
      password: dotenv.get('USER_PASS'),
    );
    return attemptResponse;
  }

  static String get _clerkSessIdTokenKey =>
      '_clerkSessionId_${_publicKey.hashCode}';

  static String get _clerkClientTokenKey =>
      '_clerkClientToken_${_publicKey.hashCode}';

  static String _getClerkJwtKey(String template) {
    return '_clerkJwt_{$template}';
  }

  static Future<String> readSessionId() async {
    return await _persistor.read(_clerkSessIdTokenKey) ?? '';
  }

  static Future<String> readClerkToken() async {
    return await _persistor.read(_clerkClientTokenKey) ?? '';
  }

  static Future<JwtTemplateToken?> readJwtTemplate(String template) async {
    final key = _getClerkJwtKey(template);
    final value = await _persistor.read(key);
    if (value == null) {
      return null;
    }

    final jsonValue = jsonDecode(value);
    return JwtTemplateToken.fromJson(jsonValue);
  }

  static Future<void> writeJwtTemplate(
      String template, String jwtValue, String sessId) async {
    final key = _getClerkJwtKey(template);
    final value = JwtTemplateToken(sessId: sessId, value: jwtValue);
    await _persistor.write(key, jsonEncode(value));
  }

  static Future<String> getTemplateToken({String template = 'supabase'}) async {
    final jwtToken = await readJwtTemplate(template);
    final sessionId = await readSessionId();

    if (sessionId.isEmpty) {
      return '';
    }

    if (jwtToken != null && sessionId == jwtToken.sessId) {
      return jwtToken.value;
    }

    final clerkToken = await readClerkToken();
    final jwtTemplateToken = await _requestTemplateToken(
      template,
      sessionId,
      clerkToken,
    );

    await writeJwtTemplate(template, jwtTemplateToken, sessionId);

    return jwtTemplateToken;
  }

  static Future<String> _requestTemplateToken(
    String template,
    String sessionId,
    String clerkToken,
  ) async {
    final url = Uri.https(
      _api.domain,
      'v1/client/sessions/$sessionId/tokens/$template',
    );
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: clerkToken,
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Request template token response error');
    }

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

class JwtTemplateToken {
  JwtTemplateToken({required this.sessId, required this.value});
  final String sessId;
  final String value;

  JwtTemplateToken.fromJson(Map<String, dynamic> json)
      : sessId = json['sessId'] as String,
        value = json['value'] as String;

  Map<String, dynamic> toJson() => {
        'sessId': sessId,
        'value': value,
      };
}

class NeedAuthException implements Exception {}
