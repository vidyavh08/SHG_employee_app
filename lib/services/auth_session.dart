import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  String? _base64Token;
  String? _username;
  int? _userId;
  int? _officeId;
  String? _officeName;
  List<String> _permissions = const [];

  bool get isLoggedIn => _base64Token != null && _base64Token!.isNotEmpty;
  String? get base64Token => _base64Token;
  String? get username => _username;
  int? get userId => _userId;
  int? get officeId => _officeId;
  String? get officeName => _officeName;
  List<String> get permissions => _permissions;

  String? get authorizationHeader =>
      _base64Token == null ? null : 'Basic $_base64Token';

  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';
  static const _keyUserId = 'auth_user_id';
  static const _keyOfficeId = 'auth_office_id';
  static const _keyOfficeName = 'auth_office_name';
  static const _keyPerms = 'auth_perms';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _base64Token = prefs.getString(_keyToken);
    _username = prefs.getString(_keyUser);
    _userId = prefs.getInt(_keyUserId);
    _officeId = prefs.getInt(_keyOfficeId);
    _officeName = prefs.getString(_keyOfficeName);
    _permissions = prefs.getStringList(_keyPerms) ?? const [];
  }

  void saveFromAuthResponse(Map<String, dynamic> response) {
    _base64Token = response['base64EncodedAuthenticationKey']?.toString();
    _username = response['username']?.toString();
    _userId = response['userId'] is int ? response['userId'] as int : null;
    _officeId = response['officeId'] is int ? response['officeId'] as int : null;
    _officeName = response['officeName']?.toString();
    final perms = response['permissions'];
    _permissions = (perms is List) ? perms.map((e) => e.toString()).toList() : const [];
    
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_base64Token != null) await prefs.setString(_keyToken, _base64Token!);
    if (_username != null) await prefs.setString(_keyUser, _username!);
    if (_userId != null) await prefs.setInt(_keyUserId, _userId!);
    if (_officeId != null) await prefs.setInt(_keyOfficeId, _officeId!);
    if (_officeName != null) await prefs.setString(_keyOfficeName, _officeName!);
    await prefs.setStringList(_keyPerms, _permissions);
  }

  Future<void> clear() async {
    _base64Token = null;
    _username = null;
    _userId = null;
    _officeId = null;
    _officeName = null;
    _permissions = const [];
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
