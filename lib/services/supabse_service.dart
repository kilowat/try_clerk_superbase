import 'package:supabase_flutter/supabase_flutter.dart';

class SupabseService {
  final SupabaseClient _client;

  SupabseService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
    Future<String> Function()? accessToken,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      accessToken: accessToken,
    );
  }

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
    if (equals != null) {
      equals.forEach((key, value) {
        query.eq(key, value);
      });
    }

    if (orderBy != null) {
      query.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      query.limit(limit);
    }

    if (offset != null) {
      query.range(offset, offset + (limit ?? 20) - 1);
    }

    final result = await query;

    return result;
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
