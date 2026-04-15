import 'api_client.dart';

class DashboardApi {
  final ApiClient _client;
  DashboardApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<Map<String, dynamic>> fetchSummary() async {
    final decoded = await _client.get('/dashboard/summary');
    return (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
  }
}
