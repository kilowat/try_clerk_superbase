import 'dart:async';

import 'package:clerk_auth/clerk_auth.dart';
import 'package:try_clerk_superbase/import.dart';

class AuthenticationRepository {
  AuthenticationRepository({
    LocalStore? storage,
    ClerkService? apiService,
    ConnectivityHandler? connectivity,
  })  : _storage = storage ?? LocalStore(),
        _apiService = apiService ?? ClerkService(),
        _connectivity = connectivity ?? ConnectivityHandler();

  final LocalStore _storage;
  final ClerkService _apiService;
  final ConnectivityHandler _connectivity;

  UserModel _currentUser = UserModel.empty;

  UserModel get currentUser => _currentUser;

  final StreamController<UserModel> _authController =
      StreamController.broadcast();

  bool get isAuthorized => _currentUser != UserModel.empty;

  Stream<UserModel> authStream() => _authController.stream;

  Future<void> authorize() async {
    try {
      _currentUser = await fetch();
      _authController.sink.add(_currentUser);
    } on NeedAuthException {
      unauthorize();
    } catch (error, stackTrace) {
      AuthorizeFailure(error).throwStack(stackTrace);
    }
  }

  Future<void> unauthorize() async {
    _currentUser = UserModel.empty;
    _authController.sink.add(_currentUser);
    return Future.value();
  }

  Future<void> login({
    required String login,
    required String password,
  }) async {
    try {
      await _apiService.signIn();
      await authorize();
    } catch (error, stackTrace) {
      LoginFailure(error).throwStack(stackTrace);
    }
  }

  Future<void> register() async {
    //to do
  }

  Future<UserModel> fetch() async {
    if (_connectivity.isConnected) {
      final response = await _apiService.profile();
      if (response == null) {
        throw NeedAuthException();
      }
      final user = response.toModel();
      await _storage.save('user', user.toSerialize());
      return user;
    } else {
      final fetchResult = await _storage.fetch('user');
      if (fetchResult == null) {
        return UserModel.empty;
      }
      return UserModel.fromSerialize(fetchResult);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.signOut();
      _currentUser = UserModel.empty;
      _authController.sink.add(_currentUser);
      _storage.remove('user');
    } catch (error, stackTrace) {
      LogoutFailure(error).throwStack(stackTrace);
    }

    ///remove
  }
}

class LoginFailure extends Failure {
  LoginFailure(super.error);
}

class LogoutFailure extends Failure {
  LogoutFailure(super.error);
}

class AuthorizeFailure extends Failure {
  AuthorizeFailure(super.error);
}

class RegisterFailure extends Failure {
  RegisterFailure(super.error);
}

extension on User {
  UserModel toModel() {
    return UserModel(id: id);
  }
}
