/// A user-presentable failure that can come from a backend request or from
/// the device being offline.
///
/// Keeping the kind separate from the message lets the UI decide what to show
/// (for example, a Retry button for connectivity problems) without having to
/// parse an exception string.
enum AppFailureKind {
  /// The device has no usable internet connection.
  offline,

  /// The request was sent but the server did not answer in time.
  timeout,

  /// The device is online but the DataNaija backend could not be reached.
  backend,

  /// The session/token is no longer valid (HTTP 401 or 403).
  unauthorized,

  /// The backend answered with an error status.
  server,

  /// The backend answered with something the app could not understand.
  invalidResponse,

  /// Anything else that should not crash the screen.
  unknown,
}

class AppFailure implements Exception {
  const AppFailure({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  const AppFailure.offline()
      : kind = AppFailureKind.offline,
        message = noInternetMessage,
        statusCode = null;

  const AppFailure.timeout()
      : kind = AppFailureKind.timeout,
        message = 'The request is taking too long. Please try again.',
        statusCode = null;

  const AppFailure.backend()
      : kind = AppFailureKind.backend,
        message = 'Unable to reach the DataNaija server. Please try again.',
        statusCode = null;

  const AppFailure.unauthorized()
      : kind = AppFailureKind.unauthorized,
        message = 'Your session has expired. Please sign in again.',
        statusCode = 401;

  const AppFailure.invalidResponse()
      : kind = AppFailureKind.invalidResponse,
        message = 'We received an unexpected response. Please try again.',
        statusCode = null;

  const AppFailure.unknown()
      : kind = AppFailureKind.unknown,
        message = 'Something went wrong. Please try again.',
        statusCode = null;

  /// The exact message required by the offline state.
  static const String noInternetMessage =
      'No internet connection. Please check your connection.';

  final AppFailureKind kind;
  final String message;
  final int? statusCode;

  bool get isOffline => kind == AppFailureKind.offline;
  bool get isUnauthorized => kind == AppFailureKind.unauthorized;

  /// Converts a caught error into a failure the UI can safely display.
  ///
  /// Network-specific exceptions are wrapped by [ApiService]; this fallback
  /// makes sure an unexpected error never leaks a raw exception string into
  /// the interface.
  static AppFailure from(Object error) {
    if (error is AppFailure) return error;
    return const AppFailure.unknown();
  }

  @override
  String toString() => message;
}
