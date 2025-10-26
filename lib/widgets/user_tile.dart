import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';
import 'package:hipster_inc_assignment/utils/user.dart';
import 'package:hipster_inc_assignment/widgets/user_tile_widget/export.dart';

class UserTile extends StatelessWidget {
  final UserModel user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => UserDetailSheet(user: user),
        );
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
          vertical: AppDimens.paddingSmall,
        ),
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: AppDimens.alphaOverlay),
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(
            color: AppColors.white.withValues(alpha: AppDimens.alphaBorder),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppDimens.avatarRadiusSmall,
              backgroundImage: NetworkImage(user.avatar),
            ),
            const SizedBox(width: AppDimens.paddingMedium),
            Expanded(
              child: Text(
                '${user.firstName} ${user.lastName}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
