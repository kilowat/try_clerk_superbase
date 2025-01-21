import 'package:try_clerk_superbase/import.dart';

abstract class ApiDatabaseRepository {
  readTodos();
}

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

class FakeDataBaseRepository implements ApiDatabaseRepository {
  @override
  readTodos() async {
    //return await _service.getList(table: API.todos);
  }
}
