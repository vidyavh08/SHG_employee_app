import 'api_client.dart';

class SurveyApi {
  final ApiClient _client;
  SurveyApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<List<dynamic>> fetchSurveys() async {
    final decoded = await _client.get('/surveys');
    if (decoded is List) return decoded;
    return const [];
  }

  Future<Map<String, dynamic>> submitSurvey(Map<String, dynamic> payload) async {
    final decoded = await _client.post('/surveys', body: payload);
    return (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
  }
}
