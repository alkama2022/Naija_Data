import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_naija_app/core/config/app_config.dart';
import 'package:data_naija_app/core/errors/app_failure.dart';
import 'package:data_naija_app/core/utils/auth_service.dart';
import 'package:data_naija_app/core/utils/connectivity_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._internal({http.Client? client, ConnectivityService? connectivity})
      : _client = client ?? http.Client(),
        _connectivity = connectivity ?? ConnectivityService.instance;

  static ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  /// Builds an isolated service for tests. It does not replace the app-wide
  /// singleton unless [setInstanceForTesting] is called.
  @visibleForTesting
  factory ApiService.withClient(
    http.Client client, {
    ConnectivityService? connectivity,
  }) =>
      ApiService._internal(client: client, connectivity: connectivity);

  @visibleForTesting
  static void setInstanceForTesting(ApiService service) {
    _instance = service;
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance = ApiService._internal();
  }

  final http.Client _client;
  final ConnectivityService _connectivity;

  /// A slow request must never leave the customer staring at a spinner.
  static const Duration requestTimeout = Duration(seconds: 15);

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && AuthService.token != null) {
      headers.addAll(AuthService.authHeaders);
    }
    return headers;
  }

  /// Runs a request with a connectivity pre-check, a timeout, and a single
  /// place that translates transport errors into [AppFailure]s.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    if (!await _connectivity.hasConnection()) {
      throw const AppFailure.offline();
    }

    try {
      return await request().timeout(requestTimeout);
    } on AppFailure {
      rethrow;
    } on TimeoutException {
      throw const AppFailure.timeout();
    } on SocketException {
      _connectivity.markOffline();
      throw const AppFailure.backend();
    } on HandshakeException {
      throw const AppFailure.backend();
    } on http.ClientException {
      throw const AppFailure.backend();
    } on FormatException {
      throw const AppFailure.invalidResponse();
    }
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    if (response.body.trim().isEmpty) return const <String, dynamic>{};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{'data': decoded};
    } on FormatException {
      return const <String, dynamic>{};
    }
  }

  AppFailure _failureFromResponse(
    http.Response response,
    Map<String, dynamic> data, {
    required String fallback,
    bool authenticated = false,
  }) {
    final serverMessage =
        (data['error'] ?? data['message'])?.toString().trim();
    final hasServerMessage =
        serverMessage != null && serverMessage.isNotEmpty;

    if (response.statusCode == 401 || response.statusCode == 403) {
      return AppFailure(
        kind: authenticated
            ? AppFailureKind.unauthorized
            : AppFailureKind.server,
        message: hasServerMessage
            ? serverMessage
            : (authenticated
                ? 'Your session has expired. Please sign in again.'
                : 'Incorrect details. Please check and try again.'),
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 500) {
      return AppFailure(
        kind: AppFailureKind.server,
        message: hasServerMessage
            ? serverMessage
            : 'DataNaija is temporarily unavailable. Please try again.',
        statusCode: response.statusCode,
      );
    }

    return AppFailure(
      kind: AppFailureKind.server,
      message: hasServerMessage ? serverMessage : fallback,
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> _getObject(
    Uri uri, {
    bool includeAuth = true,
    required String failureMessage,
  }) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final response = await _send(() => _client.get(uri, headers: headers));
    final data = _decodeMap(response);

    if (response.statusCode == 200) return data;
    throw _failureFromResponse(
      response,
      data,
      fallback: failureMessage,
      authenticated: includeAuth,
    );
  }

  Future<Map<String, dynamic>> signIn(String phone, String password) async {
    final headers = await _getHeaders(includeAuth: false);
    final response = await _send(
      () => _client.post(
        Uri.parse('${AppConfig.apiUrl}/auth/signin'),
        headers: headers,
        body: jsonEncode({'phone': phone, 'password': password}),
      ),
    );

    final data = _decodeMap(response);
    if (response.statusCode == 200) {
      final token = data['token'];
      if (token is! String || token.isEmpty) {
        throw const AppFailure.invalidResponse();
      }
      await AuthService.saveToken(token);
      final user = data['user'];
      if (user is Map) {
        await AuthService.saveUser(Map<String, dynamic>.from(user));
      }
      return data;
    }

    throw _failureFromResponse(response, data, fallback: 'Sign in failed');
  }

  Future<Map<String, dynamic>> signUp(
    String fullName,
    String phone,
    String email,
    String password,
  ) async {
    final headers = await _getHeaders(includeAuth: false);
    final response = await _send(
      () => _client.post(
        Uri.parse('${AppConfig.apiUrl}/auth/signup'),
        headers: headers,
        body: jsonEncode({
          'fullName': fullName,
          'phone': phone,
          'email': email,
          'password': password,
        }),
      ),
    );

    final data = _decodeMap(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data['token'];
      if (token is! String || token.isEmpty) {
        throw const AppFailure.invalidResponse();
      }
      await AuthService.saveToken(token);
      final user = data['user'];
      if (user is Map) {
        await AuthService.saveUser(Map<String, dynamic>.from(user));
      }
      return data;
    }

    throw _failureFromResponse(response, data, fallback: 'Sign up failed');
  }

  /// Confirms that a saved token is still accepted by the backend.
  ///
  /// Returns normally for a valid session. A 401/403 clears the saved token
  /// so the app can follow the normal signed-out flow instead of showing
  /// protected screens with an expired session.
  Future<void> verifySession() async {
    final headers = await _getHeaders();
    final response = await _send(
      () => _client.get(
        Uri.parse('${AppConfig.apiUrl}/wallet/balance'),
        headers: headers,
      ),
    );
    final data = _decodeMap(response);

    if (response.statusCode == 200) return;

    final failure = _failureFromResponse(
      response,
      data,
      fallback: 'Your session could not be verified. Please try again.',
      authenticated: true,
    );
    if (failure.isUnauthorized) {
      await AuthService.clearAuth();
    }
    throw failure;
  }

  Future<Map<String, dynamic>> getWalletBalance() {
    return _getObject(
      Uri.parse('${AppConfig.apiUrl}/wallet/balance'),
      failureMessage: 'Failed to get balance',
    );
  }

  Future<Map<String, dynamic>> purchaseDataBundle({
    required String network,
    required String type,
    String? dataType,
    required String phone,
    String? planId,
  }) async {
    final headers = await _getHeaders();
    final response = await _send(
      () => _client.post(
        Uri.parse('${AppConfig.apiUrl}/purchase'),
        headers: headers,
        body: jsonEncode({
          'network': network,
          'type': type,
          'dataType': dataType,
          'phone': phone,
          'planId': planId,
        }),
      ),
    );

    final data = _decodeMap(response);
    if (response.statusCode == 200) return data;
    throw _failureFromResponse(
      response,
      data,
      fallback: 'Purchase failed',
      authenticated: true,
    );
  }

  Future<List<dynamic>> getTransactions() async {
    final data = await _getObject(
      Uri.parse('${AppConfig.apiUrl}/wallet/transactions'),
      failureMessage: 'Failed to get transactions',
    );
    final transactions = data['transactions'];
    return transactions is List ? transactions : const <dynamic>[];
  }

  Future<List<dynamic>> getNetworks() async {
    final data = await _getObject(
      Uri.parse('${AppConfig.apiUrl}/networks'),
      includeAuth: false,
      failureMessage: 'Failed to get networks',
    );
    final networks = data['networks'];
    return networks is List ? networks : const <dynamic>[];
  }

  Future<List<dynamic>> getDataPlans(String network, String type) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/data-plans').replace(
      queryParameters: {'network': network, 'type': type},
    );
    final data = await _getObject(
      uri,
      includeAuth: false,
      failureMessage: 'Failed to get plans',
    );
    final plans = data['plans'];
    return plans is List ? plans : const <dynamic>[];
  }

  void dispose() {
    _client.close();
  }
}
