import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import 'package:hipster_inc_assignment/utils/app_text_styles.dart';

class ChannelInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onJoinChannel;

  const ChannelInputWidget({
    super.key,
    required this.controller,
    required this.onJoinChannel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(AppStrings.joinPrompt, style: AppTextStyles.body),
        const SizedBox(height: AppDimens.marginVideoCallSmall),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: AppStrings.channelHint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.textWhite
                .withValues(alpha: AppDimens.alphaLowVideoCall),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(AppDimens.radiusMediumVideoCall),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            prefixIcon:
            const Icon(Icons.meeting_room, color: AppColors.textMuted),
          ),
          onFieldSubmitted: (_) => onJoinChannel(),
        ),
        const SizedBox(height: AppDimens.marginVideoCallSmall),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(AppDimens.radiusMediumVideoCall),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingVideoCallMedium),
            ),
            onPressed: onJoinChannel,
            child: const Text(AppStrings.joinButton,
                style: AppTextStyles.button),
          ),
        ),
        const SizedBox(height: AppDimens.marginVideoCallTiny),
        const Text(
          AppStrings.bothUsersHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}