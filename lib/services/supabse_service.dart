import 'package:supabase_flutter/supabase_flutter.dart';

class SupabseService {
  final SupabaseClient _client;

  SupabseService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  static const _defaultSelect = '*';

  Future<List<Map<String, dynamic>>> getList({
    required String table,
    String? select,
    Map<String, dynamic>? equals,
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    var query = _client.from(table).select(select ?? _defaultSelect);

    // Добавляем условия equals если они есть
    if (equals != null) {
      equals.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    // Добавляем сортировку если указана
    if (orderBy != null) {
      // query = query.order(orderBy, ascending: ascending);
    }

    // Добавляем пагинацию если указана
    if (limit != null) {
      // query = query.limit(limit);
    }

    if (offset != null) {
      //  query = query.range(offset, offset + (limit ?? 20) - 1);
    }

    return await query;
  }

  Future<Map<String, dynamic>?> getOne({
    required String table,
    required String id,
    String? select,
  }) async {
    final response = await _client
        .from(table)
        .select(select ?? _defaultSelect)
        .eq('id', id)
        .single();

    return response;
  }

  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
    String? select,
  }) async {
    final response = await _client
        .from(table)
        .insert(data)
        .select(select ?? _defaultSelect)
        .single();

    return response;
  }

  Future<Map<String, dynamic>> upsert({
    required String table,
    required Map<String, dynamic> data,
    String? select,
  }) async {
    final response = await _client
        .from(table)
        .upsert(data)
        .select(select ?? _defaultSelect)
        .single();

    return response;
  }
}
