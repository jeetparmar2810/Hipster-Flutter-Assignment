import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';

import '../routes/app_routes.dart';
import '../utils/app_dimens.dart';
import '../utils/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: AppDimens.durationMS), () {
      if (!mounted) return;
      AppRoutes.navigateToLogin(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(AppStrings.appLogo),
              width: AppDimens.splashIconSize,
              height: AppDimens.splashIconSize,
            ),
            SizedBox(height: AppDimens.paddingMedium),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: AppDimens.splashTextSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
