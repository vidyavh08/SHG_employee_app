import 'api_client.dart';

class CollectionApi {
  final ApiClient _client;
  CollectionApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<List<dynamic>> fetchPendingCollections() async {
    final decoded = await _client.get('/collections/pending');
    if (decoded is List) return decoded;
    return const [];
  }

  Future<Map<String, dynamic>> recordCollection(Map<String, dynamic> payload) async {
    final decoded = await _client.post('/collections', body: payload);
    return (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
  }
}
