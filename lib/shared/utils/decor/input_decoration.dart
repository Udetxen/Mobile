import 'package:flutter/material.dart';
import 'package:udetxen/shared/config/theme/colors.dart';

InputDecoration getInputDecoration(BuildContext context,
    {String? hintText, String? labelText}) {
  final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
  final fillColor =
      isDarkTheme ? AppColors.backgroundDark : AppColors.backgroundLight;
  final enabledBorderColor =
      isDarkTheme ? AppColors.primaryDark : AppColors.primaryLight;

  return InputDecoration(
    fillColor: fillColor,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: enabledBorderColor, width: 2.0),
    ),
    hintText: hintText,
    labelText: labelText,
    filled: true,
    contentPadding: const EdgeInsets.all(12.0),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.secondary, width: 2.0),
    ),
  );
}
