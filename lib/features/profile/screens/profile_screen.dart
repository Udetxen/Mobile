import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/screens/login_screen.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/notification_util.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';
import 'package:provider/provider.dart';
import '../../auth/models/user_model.dart';
import 'profile_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => const AuthenticatedLayout(currentIndex: 1),
    );
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();

    return StreamBuilder<UserModel?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user.displayName ?? 'N/A'}'),
                Text('Email: ${user.email ?? 'N/A'}'),
                Text('Bio: ${user.bio ?? 'N/A'}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      ProfileSettingsScreen.route(),
                    );

                    if (result == true) {
                      await authService.updateUserInStream();

                      final notificationUtil =
                          Provider.of<NotificationUtil>(context, listen: false);

                      await notificationUtil.showNotification(
                        title: 'Profile Updated',
                        body: 'Your profile has been updated successfully.',
                        payload: 'profile_updated',
                      );
                    }
                  },
                  child: const Text('Edit Profile'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await authService.signOut();
                    if (mounted) {
                      Navigator.pushReplacement(context, LoginScreen.route());
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
