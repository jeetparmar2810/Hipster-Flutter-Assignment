import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';

class NoDataWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final double iconSize;
  final Color iconColor;
  final TextStyle? textStyle;
  final VoidCallback? onRetry;

  const NoDataWidget({
    super.key,
    required this.icon,
    required this.message,
    this.iconSize = AppDimens.iconLarge,
    this.iconColor = AppColors.primary,
    this.textStyle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: AppDimens.paddingSmall),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: AppDimens.textMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimens.paddingMedium),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh,
                  size: AppDimens.iconSmall,
                ),
                label: const Text(AppStrings.retry),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
