import 'package:flutter/material.dart';

// Colour palette
class AppColors {
  static const navy       = Color(0xFF0D1B2A);
  static const navyLight  = Color(0xFF1A2D42);
  static const navyCard   = Color(0xFF162335);
  static const gold       = Color(0xFFE8B84B);
  static const goldLight  = Color(0xFFF5CC6B);
  static const white      = Color(0xFFFFFFFF);
  static const grey       = Color(0xFF8A9BB0);
  static const greyLight  = Color(0xFFB0BEC5);
  static const error      = Color(0xFFE57373);
  static const success    = Color(0xFF66BB6A);
}

// ThemeData
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.gold,
      secondary: AppColors.goldLight,
      surface:   AppColors.navyLight,
      error:     AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color:      AppColors.white,
        fontSize:   18,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.navyLight,
      selectedItemColor:    AppColors.gold,
      unselectedItemColor:  AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.white, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.greyLight, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.grey, fontSize: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navyCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navyLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: const TextStyle(color: AppColors.grey),
      labelStyle: const TextStyle(color: AppColors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardTheme(
      color:        AppColors.navyCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.navyCard,
      selectedColor: AppColors.gold,
      labelStyle: const TextStyle(color: AppColors.white, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
  );
}

// Service categories
const kCategories = [
  'All',
  'Cafés',
  'Restaurants',
  'Hospitals',
  'Police Stations',
  'Libraries',
  'Parks',
  'Tourist Attractions',
  'Pharmacies',
  'Utility Offices',
];
