import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/profile/services/profile_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';
import 'package:udetxen/shared/types/models/user.dart' as user_model;

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
    return StreamBuilder<user_model.User?>(
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
                  Stack(
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            debugPrint('asdasdsa');
                          },
                          child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: const Color.fromARGB(255, 231, 224, 5)
                                    .withOpacity(1),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 18.0, color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    initialValue: user.displayName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                      label:const Text('Name'),
                      prefixIcon:const Icon(Icons.person_outline_rounded),
                      prefixIconColor: Colors.blue,
                      floatingLabelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2,color: const Color.fromARGB(255, 58, 124, 177))
                      )
                    ),
                    onSaved: (value) => _displayName = value,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: user.bio,
                    decoration:InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                      label:const Text('Bio'),
                      prefixIcon:const Icon(Icons.note),
                      prefixIconColor: Colors.blue,
                      floatingLabelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2,color: const Color.fromARGB(255, 58, 124, 177))
                      )
                    ),
                    onSaved: (value) => _bio = value,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProfile,
                     style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[600],
                              side: BorderSide.none,
                              shape:  StadiumBorder()),
                    child:  Text('Save', style: Theme.of(context).textTheme.labelSmall,),
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

      final updatedUser = user_model.User(
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
