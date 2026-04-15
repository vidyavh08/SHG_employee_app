import 'api_client.dart';

class ProfileApi {
  final ApiClient _client;
  ProfileApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<Map<String, dynamic>> fetchProfile() async {
    final decoded = await _client.get('/users/me');
    return (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    final decoded = await _client.put('/users/me', body: payload);
    return (decoded is Map<String, dynamic>) ? decoded : <String, dynamic>{};
  }
}
