import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const CustomBackButton({super.key, this.onPressed, this.color, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: color ?? AppColors.white,
          size: size,
        ),
      ),
    );
  }
}
