import 'dart:async';

import 'package:try_clerk_superbase/import.dart';

class AuthenticationRepository {
  AuthenticationRepository({
    ClerkService? service,
  }) : _service = service ?? ClerkService();

  final ClerkService _service;

  UserModel _currentUser = UserModel.empty;

  final StreamController<UserModel> _authController =
      StreamController.broadcast();

  bool get isAuthorized => _currentUser != UserModel.empty;

  Stream<UserModel> authStream() => _authController.stream;

  UserModel get currentUser => _currentUser;

  login() async {
    await _service.signIn();
  }

  logout() async {
    await _service.signOut();
  }
}
