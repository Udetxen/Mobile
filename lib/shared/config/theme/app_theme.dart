import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
    cardColor: AppColors.card,
    dividerColor: AppColors.divider,
    focusColor: AppColors.focus,
    highlightColor: AppColors.highlight,
    hintColor: AppColors.hint,
    hoverColor: AppColors.hover,
    shadowColor: AppColors.shadow,
    splashColor: AppColors.splash,
    unselectedWidgetColor: AppColors.unselectedWidget,
    appBarTheme: const AppBarTheme(
      color: AppColors.primaryLight,
      iconTheme: IconThemeData(color: AppColors.cardDark),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      unselectedItemColor: AppColors.hint,
      selectedItemColor: AppColors.primaryLight,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryLight,
      textTheme: ButtonTextTheme.normal,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(foregroundColor: AppColors.primaryLight),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryLight),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryLight),
    primaryIconTheme: const IconThemeData(color: AppColors.primaryLight),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryLight),
      bodyMedium: TextStyle(color: AppColors.primaryLight),
    ),
    primaryTextTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryLight),
      bodyMedium: TextStyle(color: AppColors.primaryLight),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    platform: TargetPlatform.android,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.primaryLight),
    ),
    splashFactory: InkRipple.splashFactory,
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.divider,
    focusColor: AppColors.focus,
    highlightColor: AppColors.highlight,
    hintColor: AppColors.hint,
    hoverColor: AppColors.hover,
    shadowColor: AppColors.shadow,
    splashColor: AppColors.splash,
    unselectedWidgetColor: AppColors.unselectedWidget,
    appBarTheme: const AppBarTheme(
      color: AppColors.primaryDark,
      iconTheme: IconThemeData(color: AppColors.card),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      unselectedItemColor: AppColors.hint,
      selectedItemColor: AppColors.primaryDark,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryDark,
      textTheme: ButtonTextTheme.primary,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(foregroundColor: AppColors.primaryDark),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryDark),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryDark),
    primaryIconTheme: const IconThemeData(color: AppColors.primaryDark),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryDark),
      bodyMedium: TextStyle(color: AppColors.primaryDark),
    ),
    primaryTextTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryDark),
      bodyMedium: TextStyle(color: AppColors.primaryDark),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    platform: TargetPlatform.android,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.primaryDark),
    ),
    splashFactory: InkRipple.splashFactory,
    useMaterial3: true,
  );
}
