import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late bool _isPasswordVisible;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    _isPasswordVisible = !widget.obscureText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordField = widget.obscureText;

    return AnimatedContainer(
      duration: Duration(milliseconds: AppDimens.durationMediumMS),
      margin: const EdgeInsets.symmetric(vertical: AppDimens.marginExtraSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: AppDimens.alphaLow,
                  ),
                  blurRadius: AppDimens.blurRadius,
                  offset: AppDimens.shadowLarge,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: isPasswordField ? !_isPasswordVisible : false,
        validator: (value) {
          final error = widget.validator?.call(value);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _hasError = error != null);
            }
          });
          return error;
        },
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppDimens.textLarge,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: AppColors.textPrimary,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceLight.withValues(
            alpha: AppDimens.alphaOverlay,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppDimens.paddingMedium,
            horizontal: AppDimens.paddingSmall,
          ),
          hintText: widget.label,
          hintStyle: TextStyle(
            color: AppColors.textPrimary.withValues(
              alpha: AppDimens.alphaMedium,
            ),
            fontSize: AppDimens.textLarge,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: _hasError
                      ? AppColors.error
                      : (_isFocused
                            ? AppColors.primaryLight
                            : AppColors.textPrimary),
                  size: AppDimens.iconMedium,
                )
              : null,
          suffixIcon: isPasswordField
              ? GestureDetector(
                  onTap: _togglePasswordVisibility,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return RotationTransition(
                            turns: Tween(
                              begin: 0.75,
                              end: 1.0,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                    child: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      key: ValueKey<bool>(_isPasswordVisible),
                      color: _hasError
                          ? AppColors.error
                          : (_isFocused
                                ? AppColors.primaryLight
                                : AppColors.textPrimary),
                      size: AppDimens.iconMedium,
                    ),
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            borderSide: BorderSide(
              color: AppColors.textPrimary.withValues(
                alpha: AppDimens.alphaLow,
              ),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            borderSide: BorderSide(color: AppColors.primaryLight, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            borderSide: BorderSide(color: AppColors.error, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            borderSide: BorderSide(color: AppColors.error, width: 1.6),
          ),
          errorStyle: TextStyle(
            color: AppColors.error.withValues(alpha: AppDimens.alphaHigh),
            fontSize: AppDimens.textSmall,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }
}
