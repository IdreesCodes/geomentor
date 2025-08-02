import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;
  final List<BoxShadow>? boxShadow;

  const AppLogo({
    Key? key,
    this.size = 80,
    this.iconSize = 40,
    this.borderRadius = 20,
    this.backgroundColor,
    this.iconColor,
    this.boxShadow,
  }) : super(key: key);

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
        child: SvgPicture.asset(
          'assets/svg/star.svg',
          width: iconSize,
          height: iconSize,
          color: iconColor ?? AppColors.secondary,
        ),
      ),
    );
  }
}
