import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';

class AppLoader extends StatelessWidget {
  final double size;

  const AppLoader({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: SizedBox(
            height: size,
            width: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: size,
                  width: size,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1F7B78),
                    ),
                  ),
                ),
                Image.asset(
                  AppStrings.imageIcon,
                  height: size * 0.8,
                  width: size * 0.8,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
