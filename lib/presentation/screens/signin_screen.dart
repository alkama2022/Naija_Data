import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/errors/app_failure.dart';
import 'package:data_naija_app/core/utils/url_launcher_helper.dart';
import 'package:data_naija_app/data/services/api_service.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_error_banner.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/checkbox_row.dart';
import 'package:flutter/material.dart';

/// Sign in screen — email/phone + password, remember me, fingerprint, sign up link.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.apiService});

  /// Injectable API service. Defaults to the app-wide [ApiService] instance;
  /// tests pass a stub so the sign in flow never touches the network.
  final ApiService? apiService;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with AppStateListener<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email or phone number')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a password with at least 6 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final apiService = _apiService;
      final phone = identifier.contains('@') ? identifier.split('@')[0] : identifier;
      final result = await apiService.signIn(phone, password);
      appStore.setPhone(result['user']?['phone'] ?? identifier);
      appStore.setSignedIn(true);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      final failure = AppFailure.from(e);
      if (mounted) {
        setState(() => _errorMessage = failure.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'DataNaija',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.02,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign in to your account to continue',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kTextMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              AppInput(
                controller: _emailController,
                label: 'Email or Phone Number',
                hint: 'Enter your email or phone number',
                keyboardType: TextInputType.emailAddress,
              ),
              AppInput(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: appStore.obscurePassword,
                suffixIcon: Icon(
                  appStore.obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                  color: kTextMuted,
                ),
                suffixOnTap: appStore.togglePasswordVisibility,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // The checkbox row needs a bounded width, so it takes the
                  // space that is left over.
                  Expanded(
                    child: CheckboxRow(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v),
                      title: 'Remember me',
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppLinkButton(
                    child: const Text('Forgot Password?'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Reset password',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          content: const Text(
                            'Password resets require a connection to DataNaija servers. '
                            'Contact support to recover your account.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: kTextMuted,
                              height: 1.45,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                final ok = await UrlLauncher.contactSupport();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? 'Opening WhatsApp support...'
                                          : 'Could not open WhatsApp. Check the installed apps.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Contact support'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_errorMessage != null) ...[
                AppErrorBanner(message: _errorMessage!),
                const SizedBox(height: 12),
              ],
              AppButton(
                onPressed: _isLoading ? null : _handleSignIn,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 10),
              // Fingerprint button (`.o` outline button)
              OutlinedButton(
                onPressed: () async {
                  if (appStore.fingerprintEnabled) {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Confirm with fingerprint',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        content: const Text(
                          'Touch the sensor to sign in.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kTextMuted,
                            height: 1.45,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Use fingerprint'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    if (!mounted) return;
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enable fingerprint in Profile > Security after signing in.',
                        ),
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;
                  if (!context.mounted) return;
                  appStore.setSignedIn(true);
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kTextPrimary,
                  side: const BorderSide(width: 1.5, color: kBorderMedium),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, size: 22, color: kAccent),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Sign in with fingerprint',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'or',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.signUp);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kTextPrimary,
                  side: const BorderSide(width: 1.5, color: kBorderMedium),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Create an Account'),
              ),
              const SizedBox(height: 22),
              const Text(
                'Secure and trusted',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
