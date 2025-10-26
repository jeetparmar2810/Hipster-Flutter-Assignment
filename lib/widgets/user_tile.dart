import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_strings.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showUserDetails(context),
      borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
      splashColor: AppColors.primaryLight.withValues(alpha: AppDimens.alphaLow),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppDimens.marginSmall,
          horizontal: AppDimens.marginMedium,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
          gradient: AppColors.primaryGradient,
          border: Border.all(
            color: AppColors.white.withValues(alpha: AppDimens.alphaBorder),
            width: AppDimens.borderWidthSmall,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: AppDimens.blurRadius,
              offset: AppDimens.shadowLarge,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingSmall,
          ),
          leading: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
            ),
            padding: const EdgeInsets.all(AppDimens.paddingXSmall),
            child: CircleAvatar(
              radius: AppDimens.avatarRadiusSmall,
              backgroundColor: AppColors.surfaceLight,
              backgroundImage: NetworkImage(user.avatar),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          title: Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.textLarge,
            ),
          ),
          subtitle: Text(
            user.email,
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: AppDimens.alphaMedium),
              fontSize: AppDimens.textMedium,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: AppDimens.iconSmall,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _UserDetailSheet(user: user),
    );
  }
}

class _UserDetailSheet extends StatelessWidget {
  final UserModel user;
  const _UserDetailSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: AppDimens.userSheetInitialSize,
      maxChildSize: AppDimens.userSheetMaxSize,
      minChildSize: AppDimens.userSheetMinSize,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusXLarge)),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: AppDimens.alphaHigh),
                AppColors.primaryDark.withValues(alpha: AppDimens.alphaHigh),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingLarge,
              vertical: AppDimens.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: AppDimens.dragHandleWidth,
                  height: AppDimens.dragHandleHeight,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: AppDimens.alphaLow),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ),
                  ),
                  padding: const EdgeInsets.all(AppDimens.paddingExtraSmall),
                  child: CircleAvatar(
                    radius: AppDimens.avatarRadiusLarge,
                    backgroundImage: NetworkImage(user.avatar),
                    onBackgroundImageError: (_, __) {},
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppDimens.textXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingSmall),
                Text(
                  user.email,
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: AppDimens.alphaMedium),
                    fontSize: AppDimens.textMedium,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                Divider(color: AppColors.white.withValues(alpha: AppDimens.alphaBorder)),
                const SizedBox(height: AppDimens.paddingLarge),
                _infoTile(
                    AppStrings.userId, user.id.toString(), Icons.badge_outlined),
                const SizedBox(height: AppDimens.paddingMedium),
                _infoTile(
                    AppStrings.email, user.email, Icons.alternate_email_outlined),
                const SizedBox(height: AppDimens.paddingMedium),
                _infoTile(
                    AppStrings.company, AppStrings.companyName, Icons.business_outlined),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.paddingSmall,
        horizontal: AppDimens.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: AppDimens.alphaOverlay),
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.white.withValues(alpha: AppDimens.alphaBorder)),
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
                    color: AppColors.white.withValues(alpha: AppDimens.alphaLow),
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