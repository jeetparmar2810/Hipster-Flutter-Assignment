import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';

class UserInfoTileWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const UserInfoTileWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.paddingSmall,
        horizontal: AppDimens.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: AppDimens.alphaOverlay),
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: AppColors.white.withValues(alpha: AppDimens.alphaBorder),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: AppDimens.iconMedium),
          const SizedBox(width: AppDimens.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.white.withValues(
                      alpha: AppDimens.alphaLow,
                    ),
                    fontSize: AppDimens.textSmall,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingExtraSmall),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: AppDimens.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
