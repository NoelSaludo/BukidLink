import 'package:flutter/material.dart';
import 'AppColors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String FONT_FAMILY = 'Outfit';
  static const String PESO_FONT_FAMILY = 'Roboto Condensed';

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
    color: AppColors.HEADER_GRADIENT_START,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
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

  // Product Info Page Text Styles
  static const TextStyle PRODUCT_INFO_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle PRODUCT_NAME_LARGE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 30.0,
    fontWeight: FontWeight.w700,
    color: AppColors.DARK_TEXT,
    letterSpacing: -0.5,
  );

  static const TextStyle PRODUCT_NAME_HEADER = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 28.0,
    fontWeight: FontWeight.w800,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle SECTION_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle SECTION_TITLE_LARGE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle CATEGORY_BADGE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.HEADER_GRADIENT_START,
  );

  static const TextStyle CATEGORY_BADGE_SMALL = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.HEADER_GRADIENT_START,
  );

  static const TextStyle RATING_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle RATING_TEXT_LARGE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle REVIEW_COUNT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle REVIEW_COUNT_MEDIUM = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle SELLER_LABEL = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle SELLER_LABEL_MEDIUM = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle SELLER_NAME = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle SELLER_NAME_LARGE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle AVAILABILITY_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle QUANTITY_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle PRICE_LARGE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryGreen,
  );

  static const TextStyle BUTTON_TEXT_LARGE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle PRICE_DISPLAY = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 18.0,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryGreen,
  );

  static const TextStyle DESCRIPTION_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    color: AppColors.TEXT_SECONDARY,
    height: 1.6,
  );

  static const TextStyle REVIEW_USER_NAME = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle REVIEW_DATE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle REVIEW_COMMENT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.DARK_TEXT,
    height: 1.5,
  );

  static const TextStyle VERIFIED_BADGE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 9.0,
    fontWeight: FontWeight.w600,
    color: AppColors.SUCCESS_GREEN,
  );

  static const TextStyle LINK_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.HEADER_GRADIENT_START,
  );

  static const TextStyle EMPTY_STATE_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle EMPTY_STATE_SUBTITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle USER_AVATAR_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // Button Text Styles
  static const TextStyle BUTTON_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // Peso Currency Symbol Style
  static const TextStyle PESO_SYMBOL = TextStyle(
    fontFamily: PESO_FONT_FAMILY,
    fontWeight: FontWeight.w400,
  );

  // ----------------------------
// Checkout Page Text Styles
// ----------------------------
  static const TextStyle CHECKOUT_SECTION_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle CHECKOUT_LABEL = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle CHECKOUT_VALUE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle CHECKOUT_PRODUCT_NAME = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle CHECKOUT_PRODUCT_DETAILS = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle CHECKOUT_PRICE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.primaryGreen,
  );

  static const TextStyle CHECKOUT_SHOP_NAME = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.primaryGreen,
  );

  static const TextStyle CHECKOUT_TOTAL_LABEL = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle CHECKOUT_TOTAL_VALUE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle CHECKOUT_BUTTON_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Colors.white,
  );

  // ----------------------------
  // Farmer Store Page Text Styles
  // ----------------------------

  // Bottom Navigation
  static const TextStyle FARMER_NAV_SELECTED = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle FARMER_NAV_UNSELECTED = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Tab Labels
  static const TextStyle FARMER_TAB_LABEL = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle FARMER_TAB_LABEL_UNSELECTED = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Sell Product Button
  static const TextStyle SELL_PRODUCT_BUTTON = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Product Card
  static const TextStyle STORE_PRODUCT_NAME = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle STORE_PRODUCT_PRICE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle STORE_PRODUCT_INFO_LABEL = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle STORE_PRODUCT_RATING = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle STORE_ACTION_BUTTON = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.DARK_TEXT,
  );

  // Empty State
  static const TextStyle FARMER_EMPTY_STATE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.TEXT_SECONDARY,
  );

  static const TextStyle DIALOG_TITLE = TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.DARK_TEXT,
  );

  static const TextStyle BODY_TEXT = TextStyle(
    fontFamily: FONT_FAMILY,
    color: AppColors.BLACK_TEXT,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );
}


