import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/profile/services/profile_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';
import '../../auth/models/user_model.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ProfileSettingsScreen(),
    );
  }

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _displayName;
  String? _bio;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: getIt<AuthService>().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            backgroundColor: Theme.of(context).hintColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: user.displayName,
                    decoration: getInputDecoration(context, labelText: 'Name'),
                    onSaved: (value) => _displayName = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: user.bio,
                    decoration: getInputDecoration(context, labelText: 'Bio'),
                    onSaved: (value) => _bio = value,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final authService = getIt<AuthService>();
      final profileService = getIt<ProfileService>();

      final user = await authService.currentUser;
      if (user == null) {
        return;
      }

      final updatedUser = UserModel(
        uid: user.uid,
        email: user.email,
        displayName: _displayName ?? user.displayName,
        photoURL: user.photoURL,
        bio: _bio ?? user.bio,
      );

      final res = await profileService.updateUserProfile(updatedUser);

      await res.on(onFailure: (e) {
        if (!mounted) return;
      }, onSuccess: (updatedUser) async {
        if (!mounted) return;

        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    }
  }
}
