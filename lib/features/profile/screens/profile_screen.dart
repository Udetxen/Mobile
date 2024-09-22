import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/screens/login_screen.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/notification_util.dart';
import 'package:udetxen/shared/utils/theme_service.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';
import 'package:provider/provider.dart';
import 'package:udetxen/shared/types/models/user.dart' as user_model;
import 'profile_settings_screen.dart';
import '../../report/screens/report_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => const AuthenticatedLayout(currentIndex: 3),
    );
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    return StreamBuilder<user_model.User?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        var img = user?.photoURL;
        debugPrint('img: $img');
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image(
                          image: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : const NetworkImage(
                                  'https://pics.freeicons.io/uploads/icons/png/7229900911605810030-512.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${user.displayName ?? 'N/A'} ${user.isAdmin ? '(Admin)' : ''}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      user.bio ?? 'N/A',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              ProfileSettingsScreen.route(),
                            );
                            if (result == true) {
                              await authService.updateUserInStream();
                              final notificationUtil =
                                  Provider.of<NotificationUtil>(context,
                                      listen: false);
                              await notificationUtil.showNotification(
                                title: 'Profile Updated',
                                body:
                                    'Your profile has been updated successfully.',
                                payload: 'profile_updated',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[600],
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: Text(
                            'Edit Profile',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          )),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    if (user.isUser)
                      ListMenu(
                        onPress: () {
                          // Navigate to the report screen
                          Navigator.push(
                            context,
                            ReportScreen.route(),
                          );
                        },
                        title: 'Report',
                        icon: Icons.report,
                        endIcon: true,
                      ),
                    // ListMenu(
                    //   onPress: () async {},
                    //   title: 'Setting',
                    //   icon: Icons.settings,
                    //   endIcon: true,
                    // ),
                    // ListMenu(
                    //   onPress: () async {},
                    //   title: 'Information',
                    //   icon: Icons.info_outline_rounded,
                    //   endIcon: true,
                    // ),
                    ListMenu(
                      onPress: () async {
                        await authService.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                              context, LoginScreen.route());
                          final theme =
                              Provider.of<ThemeService>(context, listen: false);
                          if (theme.isDarkMode) {
                            theme.toggleThemeMode();
                          }
                        }
                      },
                      title: 'Logout',
                      icon: Icons.logout,
                      endIcon: false,
                    )
                  ],
                )),
          ),
        );
      },
    );
  }
}

class ListMenu extends StatelessWidget {
  const ListMenu({
    super.key,
    required this.onPress,
    required this.icon,
    required this.title,
    this.endIcon = true,
  });
  final String title;
  final IconData icon;
  final bool endIcon;
  final VoidCallback onPress;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListTile(
        onTap: onPress,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.blue.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: endIcon
            ? Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: const Icon(Icons.arrow_right,
                    size: 18.0, color: Colors.grey))
            : null,
      ),
    );
  }
}
