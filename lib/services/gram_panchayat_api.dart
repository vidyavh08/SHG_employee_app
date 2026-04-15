import 'api_client.dart';

class GramPanchayatApi {
  final ApiClient _client;
  GramPanchayatApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<List<dynamic>> fetchPanchayats() async {
    final decoded = await _client.get('/grampanchayats');
    if (decoded is Map && decoded['pageItems'] is List) {
      return decoded['pageItems'] as List;
    }
    if (decoded is List) return decoded;
    return const [];
  }
}
