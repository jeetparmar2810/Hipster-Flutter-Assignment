import 'package:flutter/material.dart';

import '../app_loader.dart';

class LoadingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: false,
      builder: (_) => Center(child: AppLoader()),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
