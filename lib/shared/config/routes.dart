import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/screens/login_screen.dart';
import 'package:udetxen/features/auth/screens/register_screen.dart';
import 'package:udetxen/features/home/screens/home_screen.dart';
import 'package:udetxen/features/profile/screens/profile_screen.dart';
import 'package:udetxen/features/profile/screens/profile_settings_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileSetting = '/profileSetting';

  static Map<String, WidgetBuilder> getAppRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      profileSetting: (context) => const ProfileSettingsScreen(),
    };
  }
}
