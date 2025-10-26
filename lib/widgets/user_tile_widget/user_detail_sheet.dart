import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import 'package:hipster_inc_assignment/utils/user.dart';
import 'package:hipster_inc_assignment/widgets/user_tile_widget/user_avatar_widget.dart';
import 'package:hipster_inc_assignment/widgets/user_tile_widget/user_info_tile_widget.dart';

class UserDetailSheet extends StatelessWidget {
  final UserModel user;

  const UserDetailSheet({super.key, required this.user});

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
              top: Radius.circular(AppDimens.radiusXLarge),
            ),
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
                _buildDragHandle(),
                const SizedBox(height: AppDimens.paddingLarge),
                UserAvatarWidget(
                  avatarUrl: user.avatar,
                  radius: AppDimens.avatarRadiusLarge,
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                _buildUserName(),
                const SizedBox(height: AppDimens.paddingSmall),
                _buildUserEmail(),
                const SizedBox(height: AppDimens.paddingLarge),
                Divider(
                  color: AppColors.white.withValues(
                    alpha: AppDimens.alphaBorder,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                _buildUserInfo(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: AppDimens.dragHandleWidth,
      height: AppDimens.dragHandleHeight,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: AppDimens.alphaLow),
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
      ),
    );
  }

  Widget _buildUserName() {
    return Text(
      '${user.firstName} ${user.lastName}',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppDimens.textXLarge,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserEmail() {
    return Text(
      user.email,
      style: TextStyle(
        color: AppColors.textPrimary.withValues(alpha: AppDimens.alphaMedium),
        fontSize: AppDimens.textMedium,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        UserInfoTileWidget(
          title: AppStrings.userId,
          value: user.id.toString(),
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: AppDimens.paddingMedium),
        UserInfoTileWidget(
          title: AppStrings.email,
          value: user.email,
          icon: Icons.alternate_email_outlined,
        ),
        const SizedBox(height: AppDimens.paddingMedium),
        UserInfoTileWidget(
          title: AppStrings.company,
          value: AppStrings.companyName,
          icon: Icons.business_outlined,
        ),
      ],
    );
  }
}
