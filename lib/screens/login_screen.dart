import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
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
    if (_formKey.currentState?.validate() ?? false) {
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
      duration: Duration(seconds: AppDimens.durationMS),
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          LoadingDialog.show(context);
        } else {
          LoadingDialog.hide(context);
        }

        if (state is AuthSuccess && mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppStrings.videoCallRoute,
          );
        }

        if (state is AuthFailure && mounted) {
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
                        Color.lerp(
                          AppColors.primary,
                          AppColors.primaryLight,
                          t,
                        ) ??
                            AppColors.primary,
                        Color.lerp(
                          AppColors.primaryLight,
                          AppColors.primary,
                          t,
                        ) ??
                            AppColors.primaryLight,
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(color: AppColors.white.withValues(alpha: AppDimens.alphaZeroFive)),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: AppStrings.appLogoTag,
                      child: Image.asset(
                        AppStrings.appLogo,
                        height: AppDimens.logoSize,
                        width: AppDimens.logoSize,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingLarge),
                    const Text(
                      AppStrings.welcomeBack,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppDimens.textXLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingExtraSmall),
                    Text(
                      AppStrings.signInSubtitle,
                      style: TextStyle(
                        color:
                        AppColors.textPrimary.withValues(alpha: AppDimens.alphaMedium),
                        fontSize: AppDimens.textMedium,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingXLarge),
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(AppDimens.radiusXLarge),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: AppDimens.blurRadius, sigmaY: AppDimens.blurRadius),
                        child: Container(
                          padding: EdgeInsets.all(AppDimens.paddingLarge),
                          width: AppDimens.width,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withValues(alpha: AppDimens.alphaBorder),
                            borderRadius:
                            BorderRadius.circular(AppDimens.radiusXLarge),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: AppDimens.alphaMedium),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: AppDimens.blurRadius,
                                offset: AppDimens.shadowSmall,
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
                                const SizedBox(height: AppDimens.paddingMedium),
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
                                const SizedBox(height: AppDimens.paddingXLarge),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: AppDimens.paddingMedium),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppDimens.radiusMedium),
                                      ),
                                      backgroundColor: AppColors.primary,
                                    ),
                                    onPressed: _onLogin,
                                    child: const Text(
                                      AppStrings.loginButton,
                                      style: TextStyle(
                                        fontSize: AppDimens.textLarge,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimens.paddingMedium),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppStrings.usersRoute,
                                    );
                                  },
                                  child: Text(
                                    AppStrings.viewUsers,
                                    style: TextStyle(
                                      color: AppColors.textPrimary
                                          .withValues(alpha: AppDimens.alphaMedium),
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
                    const SizedBox(height: AppDimens.paddingXXLarge),
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