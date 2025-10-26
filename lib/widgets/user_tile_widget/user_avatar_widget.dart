import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';

class UserAvatarWidget extends StatelessWidget {
  final String avatarUrl;
  final double radius;

  const UserAvatarWidget({
    super.key,
    required this.avatarUrl,
    this.radius = AppDimens.avatarRadiusSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
      ),
      padding: const EdgeInsets.all(AppDimens.paddingXSmall),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceLight,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {},
      ),
    );
  }
}
