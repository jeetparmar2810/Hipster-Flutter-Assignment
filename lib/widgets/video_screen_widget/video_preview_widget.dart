import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';

class VideoPreviewWidget extends StatelessWidget {
  final Widget localVideoWidget;
  final bool videoEnabled;
  final bool isScreenSharing;

  const VideoPreviewWidget({
    super.key,
    required this.localVideoWidget,
    required this.videoEnabled,
    required this.isScreenSharing,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppDimens.positionVideoCallTop,
      right: AppDimens.positionVideoCallRight,
      width: AppDimens.videoPreviewWidth,
      height: AppDimens.videoPreviewHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusMediumVideoCall),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textWhite
                  .withValues(alpha: AppDimens.alphaBorderVideoCall),
              width: AppDimens.borderWidthVideoCall,
            ),
            borderRadius:
            BorderRadius.circular(AppDimens.radiusMediumVideoCall),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: AppDimens.alphaShadowVideoCall),
                blurRadius: AppDimens.blurRadiusVideoCall,
              ),
            ],
          ),
          child: Stack(
            children: [
              (videoEnabled || isScreenSharing)
                  ? localVideoWidget
                  : Container(
                color: Colors.black87,
                child: const Center(
                  child: Icon(
                    Icons.videocam_off,
                    color: AppColors.textMuted,
                    size: AppDimens.iconMediumVideoCall,
                  ),
                ),
              ),
              if (isScreenSharing)
                Positioned(
                  bottom: AppDimens.positionVideoCallBottom,
                  left: AppDimens.positionVideoCallLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingVideoCallSmall,
                      vertical: AppDimens.paddingVideoCallTiny,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                      BorderRadius.circular(AppDimens.radiusTinyVideoCall),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.screen_share,
                            size: AppDimens.iconTinyVideoCall,
                            color: Colors.black),
                        SizedBox(width: AppDimens.marginVideoCallTiny),
                        Text(AppStrings.sharing,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: AppDimens.textTinyVideoCall,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}