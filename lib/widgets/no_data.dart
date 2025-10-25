import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';

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
    this.iconSize = 40,
    this.iconColor =  AppColors.primary,
    this.textStyle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Retry"),
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