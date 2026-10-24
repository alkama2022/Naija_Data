import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility for launching URLs with graceful failure handling.
///
/// Provides a consistent way to open external links (e.g. WhatsApp deep
/// links) and shows a user-visible fallback when the link cannot be opened
/// directly (for example, when WhatsApp is not installed).
class UrlLauncher {
  UrlLauncher._();

  /// Attempts to launch [url]. Returns `true` if the launch succeeded.
  ///
  /// If the direct launch fails (e.g. WhatsApp app not installed), this
  /// falls back to opening the URL in a browser. Shows a snackbar-style
  /// message is not handled here — callers are responsible for surfacing
  /// errors to the user via [ScaffoldMessenger] or similar.
  static Future<bool> launch(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    // Fallback: try launching as a web URL in the browser.
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }

    return false;
  }

  /// Opens a direct WhatsApp conversation with the configured support number.
  static Future<bool> contactSupport() {
    return launch(kWhatsAppDirectLink);
  }

  /// Opens the configured WhatsApp Channel.
  static Future<bool> followChannel() {
    return launch(kWhatsAppChannelUrl);
  }
}
