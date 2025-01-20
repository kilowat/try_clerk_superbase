import 'package:try_clerk_superbase/services/clerk_service.dart';

class AuthenticationRepository {
  AuthenticationRepository({ClerkService? service})
      : _service = service ?? ClerkService();
  final ClerkService _service;

  login() async {
    await _service.signin();
  }

  logout() async {
    await _service.signOut();
  }
}
