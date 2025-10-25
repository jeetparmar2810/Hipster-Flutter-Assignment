import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/user_list_screen.dart';
import '../screens/video_call_screen.dart';
import '../utils/app_strings.dart';

class AppRoutes {
  static const String login = AppStrings.loginRoute;
  static const String users = AppStrings.usersRoute;
  static const String videoCall = AppStrings.videoCallRoute;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case users:
        return MaterialPageRoute(
          builder: (_) => const UserListScreen(),
        );

      case videoCall:
        final args = settings.arguments as Map<String, dynamic>?;
        final channelName = args?[AppStrings.channelNameArg] as String?;
        return MaterialPageRoute(
          builder: (_) => VideoCallScreen(channelName: channelName),
        );
      default:
        return _errorRoute(settings.name);
    }
  }

  static MaterialPageRoute _errorRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No route defined for "$name"',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void navigateToUsers(BuildContext context) {
    Navigator.pushReplacementNamed(context, users);
  }

  static void navigateToVideoCall(
      BuildContext context, {
        String? channelName,
      }) {
    Navigator.pushNamed(
      context,
      videoCall,
      arguments: {AppStrings.channelNameArg: channelName},
    );
  }
}