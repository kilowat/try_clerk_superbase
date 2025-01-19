import 'package:try_clerk_superbase/repositories/api.dart';
import 'package:try_clerk_superbase/services/supabse_service.dart';

class DatabaseRepository {
  DatabaseRepository({
    SupabseService? service,
  }) : _service = service ?? SupabseService();

  final SupabseService _service;

  readTodos() async {
    return await _service.getList(table: API.todos);
  }
}
