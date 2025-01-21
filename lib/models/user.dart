import 'dart:convert';

class UserModel {
  const UserModel({
    required this.id,
  });
  final String id;

  static const empty = UserModel(id: '');

  factory UserModel.fromSerialize(String str) {
    final json = jsonDecode(str);
    return UserModel.fromJson(json);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
    );
  }

  String toSerialize() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
