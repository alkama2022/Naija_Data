// Unit tests for the connectivity probe used before showing the app and
// before every backend request.

import 'dart:io';

import 'package:data_naija_app/core/utils/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivity extends ConnectivityService {
  _FakeConnectivity(this.online);

  final bool online;
  int calls = 0;

  @override
  Future<bool> hasConnection({bool force = false}) async {
    calls++;
    return online;
  }
}

void main() {
  setUp(() {
    ConnectivityService.resetForTesting();
  });

  group('ConnectivityService', () {
    test('reports online when the device can resolve a host', () async {
      final service = _FakeConnectivity(true);
      expect(await service.hasConnection(), isTrue);
      expect(service.calls, 1);
    });

    test('reports offline when the device cannot resolve a host', () async {
      final service = _FakeConnectivity(false);
      expect(await service.hasConnection(), isFalse);
      expect(service.calls, 1);
    });

    test('caches the result for a short while', () async {
      var calls = 0;
      final service = ConnectivityService(
        probe: () async {
          calls++;
          return true;
        },
        cacheDuration: const Duration(seconds: 5),
      );

      expect(await service.hasConnection(), isTrue);
      expect(calls, 1);

      // Within the cache window the second call reuses the first answer
      // instead of starting another probe.
      expect(await service.hasConnection(), isTrue);
      expect(calls, 1);
    });

    test('forces a new probe when force is requested', () async {
      var calls = 0;
      final service = ConnectivityService(
        probe: () async {
          calls++;
          return true;
        },
        cacheDuration: const Duration(seconds: 5),
      );

      expect(await service.hasConnection(), isTrue);
      expect(await service.hasConnection(force: true), isTrue);
      expect(calls, 2);
    });

    test('marks the device offline after a network-level failure', () async {
      final service = ConnectivityService(
        probe: () async => true,
        cacheDuration: const Duration(seconds: 5),
      );

      expect(await service.hasConnection(), isTrue);
      service.markOffline();
      expect(await service.hasConnection(), isFalse);
    });

    test('shares one in-flight probe between concurrent callers', () async {
      var calls = 0;
      final service = ConnectivityService(
        probe: () async {
          calls++;
          await Future<void>.delayed(Duration.zero);
          return true;
        },
        cacheDuration: Duration.zero,
      );

      final results = await Future.wait([
        service.hasConnection(),
        service.hasConnection(),
        service.hasConnection(),
      ]);

      expect(results, [isTrue, isTrue, isTrue]);
      expect(calls, 1);
    });

    test('treats a failing probe as offline', () async {
      final service = ConnectivityService(
        probe: () async => throw SocketException('no route'),
        cacheDuration: Duration.zero,
      );
      expect(await service.hasConnection(), isFalse);
    });
  });
}
