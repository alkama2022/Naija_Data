import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Answers one question: can this device currently reach the internet?
///
/// The app deliberately does not depend on a connectivity package. A DNS
/// lookup is enough to tell "the phone is offline" apart from "the DataNaija
/// backend is down", and the result is cached briefly so a screen does not
/// repeat the probe for every request.
class ConnectivityService {
  ConnectivityService({
    Future<bool> Function()? probe,
    this.probeTimeout = const Duration(seconds: 4),
    this.cacheDuration = const Duration(seconds: 5),
  }) : _probe = probe;

  /// The instance the app uses. Tests can replace this with a deterministic
  /// probe, and [resetForTesting] puts the real one back.
  static ConnectivityService instance = ConnectivityService();

  final Future<bool> Function()? _probe;
  final Duration probeTimeout;
  final Duration cacheDuration;

  bool? _lastResult;
  DateTime? _lastCheckedAt;
  Future<bool>? _inFlight;

  /// Whether the last check found a connection.
  ///
  /// Returns `null` until [hasConnection] has completed at least once.
  bool? get lastKnownResult => _lastResult;

  /// Returns `true` when the device can resolve a public host.
  ///
  /// [force] bypasses the short cache. Concurrent callers share the same
  /// in-flight probe so a burst of requests cannot start several lookups.
  Future<bool> hasConnection({bool force = false}) {
    final checkedAt = _lastCheckedAt;
    if (!force &&
        _lastResult != null &&
        checkedAt != null &&
        DateTime.now().difference(checkedAt) < cacheDuration) {
      return Future<bool>.value(_lastResult!);
    }

    final running = _inFlight;
    if (running != null) return running;

    final future = _runProbe();
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
  }

  Future<bool> _runProbe() async {
    bool online;
    try {
      online = await (_probe?.call() ?? _defaultProbe()).timeout(probeTimeout);
    } catch (_) {
      online = false;
    }

    _lastResult = online;
    _lastCheckedAt = DateTime.now();
    return online;
  }

  Future<bool> _defaultProbe() async {
    // More than one host makes a single blocked/overloaded DNS resolver
    // unlikely to produce a false "offline" result.
    const hosts = ['one.one.one.one', 'cloudflare.com', 'google.com'];
    for (final host in hosts) {
      try {
        final addresses = await InternetAddress.lookup(host).timeout(
          probeTimeout,
        );
        if (addresses.any((address) => address.rawAddress.isNotEmpty)) {
          return true;
        }
      } catch (_) {
        // Try the next host.
      }
    }
    return false;
  }

  /// Marks the connection as unavailable after a network-level failure.
  ///
  /// This only updates the cache; the next non-forced call will re-check
  /// after [cacheDuration].
  void markOffline() {
    _lastResult = false;
    _lastCheckedAt = DateTime.now();
  }

  /// Forgets the cached result, for example when the app is resumed.
  void clearCache() {
    _lastResult = null;
    _lastCheckedAt = null;
  }

  /// Replaces the shared instance. Intended for tests only.
  @visibleForTesting
  static void resetForTesting({ConnectivityService? instance}) {
    ConnectivityService.instance = instance ?? ConnectivityService();
  }
}
