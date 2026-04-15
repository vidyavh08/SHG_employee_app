import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/env_config.dart';
import 'auth_session.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? body;
  ApiException(this.statusCode, this.message, [this.body]);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 30);
  static const String _tag = 'API';

  String? _authHeader() => AuthSession.instance.authorizationHeader;

  Map<String, String> _headers({bool authenticated = true, bool json = true}) {
    final headers = <String, String>{
      'Fineract-Platform-TenantId': EnvConfig.tenantId,
    };
    if (json) headers['Content-Type'] = 'application/json';
    if (authenticated) {
      final auth = _authHeader();
      if (auth == null) {
        throw ApiException(401, 'Not authenticated. Please log in.');
      }
      headers['Authorization'] = auth;
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final base = EnvConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final qp = query?.map((k, v) => MapEntry(k, v.toString()));
    return Uri.parse('$base$cleanPath').replace(queryParameters: qp);
  }

  // ---------- logging ----------

  bool get _logEnabled => EnvConfig.isDevMode;

  void _log(String message) {
    if (!_logEnabled) return;
    for (final line in message.split('\n')) {
      debugPrint('[$_tag] $line');
    }
  }

  Map<String, String> _maskHeaders(Map<String, String> headers) {
    final masked = Map<String, String>.from(headers);
    if (masked.containsKey('Authorization')) {
      final v = masked['Authorization']!;
      masked['Authorization'] =
          v.length > 14 ? '${v.substring(0, 10)}…<redacted>' : '<redacted>';
    }
    return masked;
  }

  String _prettyBody(Object? body) {
    if (body == null) return '';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      if (body is String) {
        if (body.isEmpty) return '';
        return encoder.convert(jsonDecode(body));
      }
      return encoder.convert(body);
    } catch (_) {
      return body.toString();
    }
  }

  void _logRequest(String method, Uri uri, Map<String, String> headers,
      {Object? body}) {
    if (!_logEnabled) return;
    final buf = StringBuffer()
      ..writeln('┌── REQUEST  $method  $uri')
      ..writeln('│ headers: ${_maskHeaders(headers)}');
    if (body != null) {
      buf.writeln('│ body:');
      for (final line in _prettyBody(body).split('\n')) {
        buf.writeln('│   $line');
      }
    }
    buf.write('└────────────────');
    _log(buf.toString());
  }

  void _logResponse(
      String method, Uri uri, http.Response response, Duration elapsed) {
    if (!_logEnabled) return;
    final buf = StringBuffer()
      ..writeln(
          '┌── RESPONSE ${response.statusCode}  $method  $uri  (${elapsed.inMilliseconds}ms)')
      ..writeln('│ headers: ${response.headers}');
    if (response.body.isNotEmpty) {
      buf.writeln('│ body:');
      for (final line in _prettyBody(response.body).split('\n')) {
        buf.writeln('│   $line');
      }
    }
    buf.write('└────────────────');
    _log(buf.toString());
  }

  void _logError(String method, Uri uri, Object error, Duration elapsed) {
    if (!_logEnabled) return;
    _log('✗ ERROR     $method  $uri  (${elapsed.inMilliseconds}ms)  $error');
  }

  // ---------- HTTP methods ----------

  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool authenticated = true}) async {
    final uri = _buildUri(path, query);
    final headers = _headers(authenticated: authenticated);
    final sw = Stopwatch()..start();
    _logRequest('GET', uri, headers);
    try {
      final response = await _client.get(uri, headers: headers).timeout(_timeout);
      sw.stop();
      _logResponse('GET', uri, response, sw.elapsed);
      return _handle(response);
    } on SocketException {
      sw.stop();
      _logError('GET', uri, 'SocketException', sw.elapsed);
      throw ApiException(0, 'No internet connection');
    }
  }

  Future<dynamic> post(String path,
      {Object? body, bool authenticated = true}) async {
    final uri = _buildUri(path);
    final headers = _headers(authenticated: authenticated);
    final sw = Stopwatch()..start();
    _logRequest('POST', uri, headers, body: body);
    try {
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      sw.stop();
      _logResponse('POST', uri, response, sw.elapsed);
      return _handle(response);
    } on SocketException {
      sw.stop();
      _logError('POST', uri, 'SocketException', sw.elapsed);
      throw ApiException(0, 'No internet connection');
    }
  }

  Future<dynamic> put(String path,
      {Object? body, bool authenticated = true}) async {
    final uri = _buildUri(path);
    final headers = _headers(authenticated: authenticated);
    final sw = Stopwatch()..start();
    _logRequest('PUT', uri, headers, body: body);
    try {
      final response = await _client
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      sw.stop();
      _logResponse('PUT', uri, response, sw.elapsed);
      return _handle(response);
    } on SocketException {
      sw.stop();
      _logError('PUT', uri, 'SocketException', sw.elapsed);
      throw ApiException(0, 'No internet connection');
    }
  }

  Future<dynamic> delete(String path, {bool authenticated = true}) async {
    final uri = _buildUri(path);
    final headers = _headers(authenticated: authenticated);
    final sw = Stopwatch()..start();
    _logRequest('DELETE', uri, headers);
    try {
      final response =
          await _client.delete(uri, headers: headers).timeout(_timeout);
      sw.stop();
      _logResponse('DELETE', uri, response, sw.elapsed);
      return _handle(response);
    } on SocketException {
      sw.stop();
      _logError('DELETE', uri, 'SocketException', sw.elapsed);
      throw ApiException(0, 'No internet connection');
    }
  }

  Future<dynamic> uploadFile(String path, File file,
      {String fieldName = 'file', bool authenticated = true}) async {
    final uri = _buildUri(path);
    final headers = _headers(authenticated: authenticated, json: false);
    final sw = Stopwatch()..start();
    _logRequest('POST', uri, headers,
        body: '<multipart file: ${file.path} '
            '(${(file.lengthSync() / 1024).toStringAsFixed(1)} KB)>');
    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: _determineMediaType(file.path),
        ));
      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      sw.stop();
      _logResponse('POST', uri, response, sw.elapsed);
      return _handle(response);
    } on SocketException {
      sw.stop();
      _logError('POST', uri, 'SocketException', sw.elapsed);
      throw ApiException(0, 'No internet connection');
    }
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }
    throw ApiException(
      response.statusCode,
      'Request failed: ${response.statusCode}',
      response.body,
    );
  }

  MediaType _determineMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
