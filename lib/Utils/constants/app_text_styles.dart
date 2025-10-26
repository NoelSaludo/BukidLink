import 'package:flutter/material.dart';
import 'app_colors.dart';

// utility class for consistent text styling throughout the app.
class AppTextStyles {
  AppTextStyles._();

  static const String FONT_FAMILY = 'Outfit';

  static const TextStyle BUKIDLINK_LOGO = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BACKGROUND_WHITE,
    fontSize: 48.0,
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
    fontWeight: FontWeight.w900, // Black weight
  );

  static const TextStyle CREATE_ACCOUNT_SUBTITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 22.0,
    fontWeight: FontWeight.w500, // Medium weight
  );

  static const TextStyle FORM_LABEL = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle POPULAR_PICKS_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 24.0,
    fontWeight: FontWeight.w900, // Black weight
  );

  static const TextStyle PRODUCT_NAME = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle FARM_NAME = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BORDER_GREY,
    fontSize: 14.0,
  );

  static const TextStyle PRODUCT_PRICE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  // Product Detail Screen Text Styles
  static const TextStyle APPBAR_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: Colors.white,
    fontSize: 35.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle DETAIL_PRICE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 27.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle DETAIL_UNIT = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 18.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle CALCULATE_BUTTON = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle PRODUCT_CATEGORY = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.CATEGORY_TEXT_GREY,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle PRODUCT_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 27.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle RATING_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle DETAIL_SECTION_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 21.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle DETAIL_DESCRIPTION = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 18.0,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle TOTAL_PRICE = TextStyle(
    fontFamily: FONT_FAMILY,
    color: Colors.white,
    fontSize: 26.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle ADD_TO_BASKET_BUTTON = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle QUANTITY_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  // General purpose text styles
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