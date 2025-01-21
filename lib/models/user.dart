class UserModel {
  const UserModel({
    required this.id,
  });
  final String id;

  static const empty = UserModel(id: '');
}
