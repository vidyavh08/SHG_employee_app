import 'api_client.dart';
import 'auth_session.dart';

class LoginApi {
  final ApiClient _client;
  LoginApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Calls Fineract POST /authentication and saves the returned
  /// base64EncodedAuthenticationKey into AuthSession for use by all
  /// subsequent API calls.
  Future<Map<String, dynamic>> login(String username, String password) async {
    final decoded = await _client.post(
      '/authentication',
      body: {'username': username, 'password': password},
      authenticated: false,
    );

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(500, 'Unexpected login response');
    }
    if (decoded['authenticated'] != true) {
      throw ApiException(401, 'Authentication failed');
    }
    AuthSession.instance.saveFromAuthResponse(decoded);
    return decoded;
  }

  void logout() => AuthSession.instance.clear();
}
