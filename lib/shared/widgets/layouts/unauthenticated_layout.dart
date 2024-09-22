import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/screens/login_screen.dart';

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
    return Scaffold(
      body: LoginScreen(email: widget.email),
    );
  }
}
