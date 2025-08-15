import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? dividerColor;
  final double fontSize;
  final FontWeight fontWeight;

  const DividerWithText({
    super.key,
    required this.text,
    this.textColor,
    this.dividerColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor ?? Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.grey[600],
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
        ),
        Expanded(child: Divider(color: dividerColor ?? Colors.grey[300])),
      ],
    );
  }
}
