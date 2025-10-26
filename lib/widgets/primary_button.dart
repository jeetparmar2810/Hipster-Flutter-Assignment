import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';

import '../utils/app_dimens.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: AppDimens.textLarge,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
