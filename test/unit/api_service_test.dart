// Unit tests for the backend API service.

import 'dart:convert';
import 'dart:typed_data';

import 'package:data_naija_app/core/utils/connectivity_service.dart';
import 'package:data_naija_app/data/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

class _StubHttpClient extends http.BaseClient {
  _StubHttpClient(this.handler);

  final Future<http.StreamedResponse> Function(Uri) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      handler(request.url);
}

class _FakeConnectivity extends ConnectivityService {
  _FakeConnectivity(this.online);

  final bool online;

  @override
  Future<bool> hasConnection({bool force = false}) async => online;
}

http.StreamedResponse _json(Object body, int status) => http.StreamedResponse(
      Stream<Uint8List>.value(
        Uint8List.fromList(utf8.encode(jsonEncode(body))),
      ),
      status,
      headers: <String, String>{'content-type': 'application/json'},
    );

void main() {
  setUp(() async {
    resetAppState();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ApiService.getTransactions', () {
    test('returns the backend list from a bare JSON array', () async {
      Uri? seenUri;
      final api = ApiService.withClient(
        _StubHttpClient((uri) async {
          seenUri = uri;
          return _json(
            <Map<String, dynamic>>[
              {
                'id': 'tx-1',
                'title': 'Data Purchase',
                'subtitle': 'MTN 1GB',
                'amount': -1000,
                'status': 'Successful',
                'phone': '08012345678',
                'ref': 'DN123456789',
                'typeKey': 'd',
                'createdAt': '2025-04-25T14:15:00.000Z',
              },
            ],
            200,
          );
        }),
        connectivity: _FakeConnectivity(true),
      );

      final transactions = await api.getTransactions();

      expect(transactions.length, 1);
      expect(transactions.first['ref'], 'DN123456789');
      expect(seenUri!.path, contains('/wallet/transactions'));
    });

    test('sends the status and query filters', () async {
      Uri? seenUri;
      final api = ApiService.withClient(
        _StubHttpClient((uri) async {
          seenUri = uri;
          return _json(<Map<String, dynamic>>[], 200);
        }),
        connectivity: _FakeConnectivity(true),
      );

      await api.getTransactions(status: 'Failed', query: 'airtime');

      expect(seenUri!.path, contains('/wallet/transactions'));
      expect(seenUri!.queryParameters['status'], 'Failed');
      expect(seenUri!.queryParameters['q'], 'airtime');
    });
  });
}
