import 'package:try_clerk_superbase/import.dart';

class SupabaseRepository implements ApiDatabaseRepository {
  SupabaseRepository({
    SupabseService? service,
  }) : _service = service ?? SupabseService();

  final SupabseService _service;

  @override
  readTodos() async {
    return await _service.getList(table: 'todos', select: '*');
  }
}
