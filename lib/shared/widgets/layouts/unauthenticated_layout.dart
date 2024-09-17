import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/screens/forgot_password_screen.dart';
import 'package:udetxen/features/auth/screens/login_screen.dart';
import 'package:udetxen/features/auth/screens/register_screen.dart';
import 'package:udetxen/shared/utils/theme_service.dart';
import 'package:provider/provider.dart';

class UnauthenticatedLayout extends StatefulWidget {
  final int initialScreen;
  final String? email;

  const UnauthenticatedLayout({
    super.key,
    this.initialScreen = 0,
    this.email,
  });

  @override
  State<UnauthenticatedLayout> createState() => _UnauthenticatedLayoutState();
}

class _UnauthenticatedLayoutState extends State<UnauthenticatedLayout> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialScreen);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: theme.toggleThemeMode,
          ),
        ],
        backgroundColor: Theme.of(context).hintColor,
      ),
      body: PageView(
        controller: _pageController,
        children: [
          LoginScreen(email: widget.email),
          const RegisterScreen(),
          const ForgotPasswordScreen(),
        ],
      ),
    );
  }
}
