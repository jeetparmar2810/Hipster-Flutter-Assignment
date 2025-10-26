import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';

class VideoControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const VideoControlButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled
            ? AppDimens.opacityDisabledVideoCall
            : AppDimens.opacityEnabledVideoCall,
        child: CircleAvatar(
          radius: AppDimens.avatarRadiusSmallVideoCall,
          backgroundColor: AppColors.textWhite.withValues(
            alpha: AppDimens.alphaBackgroundVideoCall,
          ),
          child: Icon(icon, color: color, size: AppDimens.iconSizeVideoCall),
        ),
      ),
    );
  }
}
