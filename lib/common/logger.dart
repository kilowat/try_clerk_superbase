import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

final class Logger {
  Logger._();

  static final Talker _instance = Logger._createTakerLogger();

  static _createTakerLogger() {
    final settings = TalkerSettings(useConsoleLogs: kDebugMode);
    final Talker talker = Talker(
      settings: settings,
    );
    return talker;
  }

  static void handle(
    Object e, [
    StackTrace? st,
    dynamic msg,
  ]) {
    _instance.handle(e, st, msg); // log to console
  }

  static void log(dynamic message) {
    _instance.log(message);
  }
}
