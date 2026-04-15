import 'api_client.dart';

class VillageApi {
  final ApiClient _client;
  VillageApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<List<dynamic>> fetchVillages({int offset = 0, int limit = 10}) async {
    final decoded = await _client.get('/villages', query: {
      'offset': offset,
      'limit': limit,
      'paged': true,
    });
    if (decoded is Map && decoded['pageItems'] is List) {
      return decoded['pageItems'] as List;
    }
    if (decoded is List) return decoded;
    return const [];
  }

  Future<dynamic> approveVillage(String villageId) {
    return _client.post('/villages/$villageId', body: {'action': 'approve'});
  }
}
