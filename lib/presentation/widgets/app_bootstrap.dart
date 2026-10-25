import 'package:data_naija_app/app.dart';
import 'package:data_naija_app/core/errors/app_failure.dart';
import 'package:data_naija_app/core/theme/app_theme.dart';
import 'package:data_naija_app/core/utils/auth_service.dart';
import 'package:data_naija_app/core/utils/connectivity_service.dart';
import 'package:data_naija_app/core/utils/storage_service.dart';
import 'package:data_naija_app/data/services/api_service.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/loading_view.dart';
import 'package:data_naija_app/presentation/widgets/retry_view.dart';
import 'package:flutter/material.dart';

enum _BootstrapStatus { loading, offline, failed, ready }

/// Starts the app with a visible loading state instead of a blank screen.
///
/// The work that used to run before `runApp` (storage, restored session,
/// local repositories and the Auto-Buy catch-up) now happens here. While it
/// runs the customer sees "Loading..." with an animated spinner.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    super.key,
    this.connectivity,
    @visibleForTesting this.initializeLocalState,
  });

  /// Injectable connectivity for tests.
  final ConnectivityService? connectivity;

  /// Replaces the local-storage/repository initialisation in tests.
  final Future<void> Function()? initializeLocalState;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  _BootstrapStatus _status = _BootstrapStatus.loading;
  String _errorMessage = '';
  bool _starting = false;
  bool _retrying = false;
  bool _localReady = false;

  ConnectivityService get _connectivity =>
      widget.connectivity ?? ConnectivityService.instance;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // A Retry tap while a start is already running must not create a second
    // initialisation (and a second set of backend calls).
    if (_starting) return;
    _starting = true;
    _retrying = true;

    if (mounted) {
      setState(() {
        _status = _BootstrapStatus.loading;
        _errorMessage = '';
      });
    }

    try {
      if (!_localReady) {
        if (widget.initializeLocalState != null) {
          await widget.initializeLocalState!();
        } else {
          await StorageService.init();
          await AuthService.init();
          appStore.restore();
          await appRepository.load();
          await autoBuyRepository.load();
        }
        _localReady = true;
      }

      // Check connectivity before showing the app. This is what turns an
      // offline launch into a clear message + Retry instead of a splash
      // screen that never gets anywhere.
      final online = await _connectivity.hasConnection(force: true);
      if (!online) {
        if (mounted) {
          setState(() => _status = _BootstrapStatus.offline);
        }
        return;
      }

      // If a token was saved, confirm it is still accepted by the backend
      // before any protected screen can be shown. A 401/403 clears the token
      // and falls through to the normal signed-out flow.
      final token = AuthService.token;
      if (token != null && token.isNotEmpty) {
        try {
          await ApiService().verifySession();
        } on AppFailure catch (failure) {
          if (failure.isUnauthorized) {
            await AuthService.clearAuth();
            appStore.setSignedIn(false);
          } else {
            rethrow;
          }
        }
      }

      // Catch up on automatic purchases that came due while the app was
      // closed. A failure here must never stop the app from starting.
      try {
        await autoBuyRepository.runDueSchedules();
      } catch (_) {
        // The rules stay in storage and will be retried on the next run.
      }

      if (mounted) {
        setState(() => _status = _BootstrapStatus.ready);
      }
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        if (failure.isOffline) {
          _status = _BootstrapStatus.offline;
        } else {
          _status = _BootstrapStatus.failed;
          _errorMessage = failure.message;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _BootstrapStatus.failed;
        _errorMessage =
            'We could not finish loading the app. Please try again.';
      });
    } finally {
      _starting = false;
      _retrying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == _BootstrapStatus.ready) {
      return const DataNaijaApp();
    }

    final Widget content;
    switch (_status) {
      case _BootstrapStatus.loading:
        content = const LoadingView();
      case _BootstrapStatus.offline:
        content = RetryView(
          message: AppFailure.noInternetMessage,
          onRetry: _start,
          retrying: _retrying,
        );
      case _BootstrapStatus.failed:
        content = RetryView(
          title: 'Could not load DataNaija',
          message: _errorMessage,
          icon: Icons.cloud_off_rounded,
          onRetry: _start,
          retrying: _retrying,
        );
      case _BootstrapStatus.ready:
        content = const LoadingView();
    }

    // The loading/offline views are shown in a real MaterialApp so they use
    // the same theme, typography and accent color as the rest of the app.
    return MaterialApp(
      title: 'DataNaija',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: content,
    );
  }
}
