import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/loader/loading_dialog.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      // Use context.read<AuthBloc>() to dispatch login event
      context.read<AuthBloc>().add(
        LoginRequested(
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap Scaffold in BlocListener to handle login states
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          LoadingDialog.show(context);
        } else {
          LoadingDialog.hide(context);
        }

        if (state is AuthSuccess) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppStrings.videoCallRoute);
        }

        if (state is AuthFailure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background gradient animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                final t = _animationController.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(AppColors.primary, AppColors.primaryLight, t)!,
                        Color.lerp(AppColors.primaryLight, AppColors.primary, t)!,
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(color: Colors.white.withValues(alpha: 0.05)),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        AppStrings.appLogo,
                        height: 110,
                        width: 110,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      AppStrings.welcomeBack,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.signInSubtitle,
                      style: TextStyle(
                        color: AppColors.textPrimary..withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          width: 400,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight..withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white..withValues(alpha: 0.7),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppTextField(
                                  controller: _emailCtrl,
                                  label: AppStrings.emailLabel,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return AppStrings.emailRequired;
                                    }
                                    if (!v.contains('@')) {
                                      return AppStrings.emailInvalid;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _passwordCtrl,
                                  label: AppStrings.passwordLabel,
                                  obscureText: true,
                                  prefixIcon: Icons.lock_outline,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return AppStrings.passwordRequired;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      backgroundColor: AppColors.primary,
                                    ),
                                    onPressed: _onLogin,
                                    child: const Text(
                                      AppStrings.loginButton,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppStrings.usersRoute);
                                  },
                                  child: Text(
                                    AppStrings.viewUsers,
                                    style: TextStyle(
                                      color: AppColors.textPrimary..withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
