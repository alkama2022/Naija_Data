import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_input.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Sign up screen — full name, email/phone, password.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with AppStateListener<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() {
    // Remember the number the account was created with so the buy flow can
    // prefill it.
    appStore.setPhone(_emailController.text.trim());
    appStore.setSignedIn(true);
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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
                keyboardType: TextInputType.phone,
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
              AppButton(
                onPressed: _handleCreateAccount,
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kTextMuted,
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
