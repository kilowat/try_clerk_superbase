import 'package:try_clerk_superbase/repositories/api_database.dart';

class FakeDataBaseRepository implements ApiDatabaseRepository {
  @override
  readTodos() async {
    //return await _service.getList(table: API.todos);
  }
}
