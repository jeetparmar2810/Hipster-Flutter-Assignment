import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import 'package:hipster_inc_assignment/utils/app_text_styles.dart';

class ConnectedLabelWidget extends StatelessWidget {
  final String channelName;
  final bool isScreenSharing;

  const ConnectedLabelWidget({
    super.key,
    required this.channelName,
    required this.isScreenSharing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingVideoCallMedium),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(
          alpha: AppDimens.alphaLowVideoCall,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMediumVideoCall),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppDimens.statusDotSizeVideoCall,
                height: AppDimens.statusDotSizeVideoCall,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.marginVideoCallSmall),
              const Text(AppStrings.connectedTo, style: AppTextStyles.body),
              Flexible(
                child: Text(
                  channelName,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (isScreenSharing) ...[
            const SizedBox(height: AppDimens.marginVideoCallSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.screen_share,
                  size: AppDimens.iconSmallVideoCall,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppDimens.marginVideoCallTiny),
                Text(
                  AppStrings.screenSharingActive,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppDimens.textSmallVideoCall,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
