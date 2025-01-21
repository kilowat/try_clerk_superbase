import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:try_clerk_superbase/import.dart';

typedef GetMessage = String Function(BuildContext);

class AppException implements Exception {
  const AppException([this.message = '']);

  final String message;
}

abstract class Failure implements Exception {
  const Failure(this.error, {this.message});

  final Object error;
  final GetMessage? message;
  // User frendly error message
  String getMessage(BuildContext context) {
    switch (error) {
      case HandshakeException _:
      case HttpException _:
      case SocketException _:
        return "Ошибка в работе сети";
      default:
        return message != null ? message!(context) : 'Произошла ошибка';
    }
  }

  Never throwStack(StackTrace stackTrace) {
    /*
    switch (error) {
      case HandshakeException _:
        break;
      case HttpException _:
        break;
      case SocketException _:
        break;
      case AppException _:
        break;
      default:
        Logger.handle(error, stackTrace);
    }
    */

    Logger.handle(error, stackTrace);
    Error.throwWithStackTrace(this, stackTrace);
  }
}
