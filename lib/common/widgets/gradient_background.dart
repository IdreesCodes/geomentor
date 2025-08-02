import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  const GradientBackground({
    Key? key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }
}
