import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import 'package:hipster_inc_assignment/utils/app_text_styles.dart';

class VideoErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const VideoErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingVideoCallLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppDimens.iconXXLargeVideoCall,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimens.marginVideoCallMedium),
            const Text(AppStrings.errorTitle, style: AppTextStyles.title),
            const SizedBox(height: AppDimens.marginVideoCallSmall),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppDimens.marginVideoCallMedium),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                AppStrings.retryButton,
                style: AppTextStyles.button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
