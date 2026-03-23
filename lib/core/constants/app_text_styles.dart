import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Заголовок 
  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
  );

  // Назви секцій 
  static const section = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedForeground,
  );

  // Текст опцій 
  static const primary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );

  // Значення
  static const value = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedForeground,
  );

  // LocalHappens
  static const headline = TextStyle( 
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
  );

  // search, subtitle
  static const bodySmall = TextStyle( 
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedForeground,
  );

  // основний текст
  static const bodyMedium = TextStyle( 
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );


  // назва картки
  static const titleSmall = TextStyle( 
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );

  static const dateTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
  );
}