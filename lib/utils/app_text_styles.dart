import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    color: AppColors.textWhite,
    fontSize: AppDimens.textLarge,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textMuted,
    fontSize: AppDimens.textMedium,
  );

  static const TextStyle error = TextStyle(
    color: AppColors.error,
    fontSize: AppDimens.textSmall,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.textWhite,
    fontSize: AppDimens.textMedium,
    fontWeight: FontWeight.w600,
  );
}
