import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';
import 'package:hipster_inc_assignment/utils/app_loader.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import 'package:hipster_inc_assignment/utils/app_text_styles.dart';

class VideoWaitingScreen extends StatelessWidget {
  final String? currentChannel;

  const VideoWaitingScreen({
    super.key,
    this.currentChannel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentChannel != null) ...[
              const AppLoader(),
              const SizedBox(height: AppDimens.marginVideoCallMedium),
              const Text(AppStrings.waitingMessage, style: AppTextStyles.body),
              const SizedBox(height: AppDimens.marginVideoCallSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingVideoCallLarge,
                  vertical: AppDimens.paddingVideoCallMedium,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textWhite
                      .withValues(alpha: AppDimens.alphaLowVideoCall),
                  borderRadius:
                  BorderRadius.circular(AppDimens.radiusLargeVideoCall),
                ),
                child: Text(
                  '${AppStrings.channelPrefix}$currentChannel',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppDimens.textLargeVideoCall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              const Icon(Icons.video_call,
                  size: AppDimens.iconXXLargeVideoCall,
                  color: AppColors.textMuted),
              const SizedBox(height: AppDimens.marginVideoCallMedium),
              const Text(AppStrings.readyMessage, style: AppTextStyles.body),
            ],
          ],
        ),
      ),
    );
  }
}