import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';

import '../utils/app_dimens.dart';

class AppLoader extends StatelessWidget {
  final double size;

  const AppLoader({super.key, this.size = AppDimens.iconXLarge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppColors.overlay.withValues(alpha: AppDimens.alphaLow),
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: SizedBox(
            height: size,
            width: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: size,
                  width: size,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                Image.asset(
                  AppStrings.imageIcon,
                  height: size * 0.8,
                  width: size * 0.8,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
