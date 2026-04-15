import 'api_client.dart';

class GroupsApi {
  final ApiClient _client;
  GroupsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<List<dynamic>> fetchGroups({int offset = 0, int limit = 20}) async {
    final decoded = await _client.get('/groups', query: {
      'offset': offset,
      'limit': limit,
    });
    if (decoded is Map && decoded['pageItems'] is List) {
      return decoded['pageItems'] as List;
    }
    if (decoded is List) return decoded;
    return const [];
  }

  Future<Map<String, dynamic>> createGroup(Map<String, dynamic> payload) async {
    final decoded = await _client.post('/groups', body: payload);
    return (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
  }
}
