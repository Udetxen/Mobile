import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/connectivity_service.dart';
import 'package:provider/provider.dart';
import '../../features/auth/models/user_model.dart';
import 'layouts/authenticated_layout.dart';
import 'no_connection_screen.dart';
import 'layouts/unauthenticated_layout.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    final isConnected = Provider.of<ConnectivityService>(context).isConnected;

    return isConnected
        ? StreamBuilder<UserModel?>(
            stream: authService.userStream,
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) {
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
