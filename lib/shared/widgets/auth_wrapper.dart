import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'package:udetxen/shared/types/models/user.dart' as user_model;
import '../utils/theme_service.dart';
import 'layouts/authenticated_layout.dart';
import 'no_connection_screen.dart';
import 'layouts/unauthenticated_layout.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    final isConnected = Provider.of<ConnectivityService>(context).isConnected;
    final theme = Provider.of<ThemeService>(context, listen: false);

    return isConnected
        ? StreamBuilder<user_model.User?>(
            stream: authService.userStream,
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) {
                if (snapshot.connectionState == ConnectionState.active) {
                  Future.microtask(() {
                    if (theme.isDarkMode) {
                      theme.toggleThemeMode();
                    }
                  });
                }

                return const UnauthenticatedLayout();
              } else {
                return AuthenticatedLayout(
                  isAdmin: user.isAdmin,
                );
              }
            })
        : const NoConnectionScreen();
  }
}
