import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/user_list_screen.dart';
import '../screens/video_call_screen.dart';
import '../utils/app_strings.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = AppStrings.loginRoute;
  static const String users = AppStrings.usersRoute;
  static const String videoCall = AppStrings.videoCallRoute;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case users:
        return MaterialPageRoute(builder: (_) => const UserListScreen());
      case videoCall:
        final args = settings.arguments;
        final channelName = (args is Map<String, dynamic>) ? args[AppStrings.channelNameArg] as String? : null;
        return MaterialPageRoute(
          builder: (_) => VideoCallScreen(channelName: channelName),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }


  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void navigateToUsers(BuildContext context) {
    Navigator.pushReplacementNamed(context, users);
  }

  static void navigateToVideoCall(BuildContext context, {String? channelName}) {
    Navigator.pushNamed(
      context,
      videoCall,
      arguments: {AppStrings.channelNameArg: channelName},
    );
  }
}