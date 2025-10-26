import 'package:flutter/material.dart';
import 'AppColors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String FONT_FAMILY = 'Outfit';

  static const TextStyle BUKIDLINK_LOGO = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BACKGROUND_WHITE,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle TOGGLE_BUTTON_ACTIVE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.DARK_TEXT,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle TOGGLE_BUTTON_INACTIVE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BORDER_GREY,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle TEXT_FIELD_HINT = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.HINT_TEXT_GREY,
    fontSize: 16.0,
  );

  static const TextStyle FORGOT_PASSWORD = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BORDER_GREY,
    fontSize: 14.0,
  );

  static const TextStyle PRIMARY_BUTTON_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.DARK_TEXT,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle HELLO_THERE_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 40.0,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle CREATE_ACCOUNT_SUBTITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 22.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle FORM_LABEL = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w800,
    fontSize: 30,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle productName = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle farmName = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle price = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle categoryLabel = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle PRODUCT_CATEGORY = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.CATEGORY_TEXT_GREY,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle BODY_MEDIUM = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle CAPTION = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.TEXT_SECONDARY,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );
}