import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;
  final List<BoxShadow>? boxShadow;

  const AppLogo({
    super.key,
    this.size = 80,
    this.iconSize = 40,
    this.borderRadius = 20,
    this.backgroundColor,
    this.iconColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/GeoMentor.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
