import 'package:try_clerk_superbase/repositories/api_database.dart';
import 'package:try_clerk_superbase/services/supabse_service.dart';

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
