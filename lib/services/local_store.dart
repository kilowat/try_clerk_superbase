class LocalStore {
  LocalStore._privateConstructor();

  static late SharedPreferences _preferences;
  static final LocalStore _instance = LocalStore._privateConstructor();

  factory LocalStore() {
    return _instance;
  }

  static Future<LocalStore> init() async {
    _preferences = await SharedPreferences.getInstance();
    return _instance;
  }

  Future<String?> fetch(String key) {
    final result = _preferences.getString(key);
    if (result != null) return Future.value(result);

    return Future<String?>.value(null);
  }

  void remove(String key) {
    _preferences.remove(key);
  }

  Future<bool> save(String key, String value) async {
    return await _preferences.setString(key, value);
  }
}
