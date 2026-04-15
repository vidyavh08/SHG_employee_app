import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String _required(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError('Missing required env var: $key');
    }
    return value;
  }

  static String get apiBaseUrl => _required('API_BASE_URL');
  static String get tenantId => _required('TENANT_ID');

  static bool get isDevMode =>
      (dotenv.maybeGet('DEV_MODE') ?? 'false').toLowerCase() == 'true';
}
