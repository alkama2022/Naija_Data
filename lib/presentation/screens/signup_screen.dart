import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/errors/app_failure.dart';
import 'package:data_naija_app/core/utils/phone_validator.dart';
import 'package:data_naija_app/data/services/api_service.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_error_banner.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Sign up screen — full name, email/phone, password.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.apiService});

  /// Injectable API service. Defaults to the app-wide [ApiService] instance;
  /// tests pass a stub so the sign up flow never touches the network.
  final ApiService? apiService;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with AppStateListener<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    final name = _nameController.text.trim();
    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your full name')),
      );
      return;
    }

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

    final phone = identifier.contains('@') && !isValidNigerianPhone(identifier)
        ? ''
        : (isValidNigerianPhone(identifier) ? identifier : identifier);
    final email = identifier.contains('@') ? identifier : '';

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final apiService = _apiService;
      await apiService.signUp(
        name,
        isValidNigerianPhone(identifier) ? identifier : phone,
        email,
        password,
      );
      if (isValidNigerianPhone(identifier)) {
        appStore.setPhone(identifier);
      }
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
              const SizedBox(height: 16),
              const Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                  letterSpacing: -0.02,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Join DataNaija and enjoy seamless VTU services',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              AppInput(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
              ),
              AppInput(
                controller: _emailController,
                label: 'Email or Phone Number',
                hint: 'Enter your email or phone number',
                keyboardType: TextInputType.emailAddress,
              ),
              AppInput(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a strong password',
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
              const SizedBox(height: 22),
              if (_errorMessage != null) ...[
                AppErrorBanner(message: _errorMessage!),
                const SizedBox(height: 12),
              ],
              AppButton(
                onPressed: _isLoading ? null : _handleCreateAccount,
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
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text(
                      'Already have an account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kTextMuted,
                      ),
                    ),
                  ),
                  AppLinkButton(
                    child: const Text('Sign in'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
