import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/dashboard.user/screens/user_management_screen.dart';
import 'package:udetxen/features/home/screens/home_screen.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/notification_util.dart';
import 'package:udetxen/shared/widgets/layouts/unauthenticated_layout.dart';

const users = {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatefulWidget {
  final String? email;

  static Route route({String? email}) {
    return MaterialPageRoute<void>(
        builder: (_) => UnauthenticatedLayout(email: email));
  }

  const LoginScreen({super.key, this.email});

  @override
  State<LoginScreen> createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen> {
  final authService = getIt<AuthService>();
  Duration get loginTime => const Duration(milliseconds: 2250);
  String errorMessage = '';

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  Future<String?> _authUser(LoginData data) async {
    // debugPrint('Name: ${data.name}, Password: ${data.password}');
    final response =
        await authService.signInWithEmail(data.name, data.password);
    await response.on(onFailure: (failure) {
      _showError(failure.userFriendlyMessage);
      errorMessage = failure.userFriendlyMessage;
    }, onSuccess: (user) {
      if (user.isAdmin) {
        Navigator.pushReplacement(context, UserManagementScreen.route());
      } else {
        Navigator.pushReplacement(context, HomeScreen.route());
      }
      errorMessage = 'Login success';
    });
    return errorMessage;
  }

  Future<String?> _signupUser(SignupData data) async {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    final response =
        await authService.registerWithEmail(data.name!, data.password!);
    await response.on(onFailure: (failure) {
      _showError(failure.userFriendlyMessage);
      errorMessage = failure.userFriendlyMessage;
    }, onSuccess: (_) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, HomeScreen.route());
    });
    return errorMessage;
  }

  Future<String?> _recoverPassword(String name) async {
    debugPrint('Name: $name');
    final response = await authService.sendPasswordResetEmail(name);
    return Future.delayed(loginTime).then((_) async {
      if (response.failure != null) {
        var asdsa = response.failure;
        debugPrint('$asdsa ');
        _showError(response.failure!.userFriendlyMessage);
        return 'Password reset failed: ${response.failure!.userFriendlyMessage}';
      } else if (mounted) {
        final notificationUtil =
            Provider.of<NotificationUtil>(context, listen: false);
        await notificationUtil.showNotification(
          title: 'Password Reset Email Sent',
          body: 'A password reset email has been sent to ${name}',
          payload: 'password_reset',
        );
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      theme: LoginTheme(
        cardTheme: const CardTheme(
          color: Colors.white,
        ),
        pageColorDark: const Color.fromARGB(255, 49, 181, 106),
        primaryColor: const Color.fromARGB(255, 33, 33, 238),
        accentColor: Colors.white,
      ),
      title: 'TNTravel',
      logo: const AssetImage('assets/images/logo.jpg'),
      onLogin: _authUser,
      onSignup: _signupUser,
      loginProviders: <LoginProvider>[
        LoginProvider(
          icon: FontAwesomeIcons.google,
          label: 'Google',
          callback: () async {
            final response = await authService.signInWithGoogle();
            await response.on(
              onFailure: (failure) {
                _showError(failure.userFriendlyMessage);
                return failure.userFriendlyMessage;
              },
              onSuccess: (user) {
                if (user.isAdmin) {
                  Navigator.pushReplacement(
                      context, UserManagementScreen.route());
                } else {
                  Navigator.pushReplacement(context, HomeScreen.route());
                }
                return null;
              },
            );
            debugPrint('start google sign in');
            await Future.delayed(loginTime);
            debugPrint('stop google sign in');
          },
        ),
        // LoginProvider(
        //   icon: FontAwesomeIcons.facebookF,
        //   label: 'Facebook',
        //   callback: () async {
        //     debugPrint('start facebook sign in');
        //     await Future.delayed(loginTime);
        //     debugPrint('stop facebook sign in');
        //     return null;
        //   },
        // ),
        // LoginProvider(
        //   icon: FontAwesomeIcons.linkedinIn,
        //   callback: () async {
        //     debugPrint('start linkdin sign in');
        //     await Future.delayed(loginTime);
        //     debugPrint('stop linkdin sign in');
        //     return null;
        //   },
        // ),
        // LoginProvider(
        //   icon: FontAwesomeIcons.githubAlt,
        //   callback: () async {
        //     debugPrint('start github sign in');
        //     await Future.delayed(loginTime);
        //     debugPrint('stop github sign in');
        //     return null;
        //   },
        // ),
      ],

      onSubmitAnimationCompleted: () {
        Navigator.pushReplacement(context, HomeScreen.route());
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
