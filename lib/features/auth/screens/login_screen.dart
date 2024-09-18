import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/screens/forgot_password_screen.dart';
import 'package:udetxen/features/auth/screens/register_screen.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/dashboard.user/screens/user_management_screen.dart';
import 'package:udetxen/features/home/screens/home_screen.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';
import 'package:udetxen/shared/widgets/layouts/unauthenticated_layout.dart';

class LoginScreen extends StatefulWidget {
  final String? email;

  static Route route({String? email}) {
    return MaterialPageRoute<void>(
        builder: (_) => UnauthenticatedLayout(email: email));
  }

  const LoginScreen({super.key, this.email});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextField(
              controller: emailController,
              decoration: getInputDecoration(context, labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: getInputDecoration(context, labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                final response = await authService.signInWithEmail(
                    emailController.text, passwordController.text);
                await response.on(
                    onFailure: (failure) =>
                        _showError(failure.userFriendlyMessage),
                    onSuccess: (user) {
                      if (user.isAdmin) {
                        Navigator.pushReplacement(
                            context, UserManagementScreen.route());
                      } else {
                        Navigator.pushReplacement(context, HomeScreen.route());
                      }
                    });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final response = await authService.signInWithGoogle();
                await response.on(
                  onFailure: (failure) =>
                      _showError(failure.userFriendlyMessage),
                  onSuccess: (user) {
                    if (user.isAdmin) {
                      Navigator.pushReplacement(
                          context, UserManagementScreen.route());
                    } else {
                      Navigator.pushReplacement(context, HomeScreen.route());
                    }
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final email =
                    await Navigator.push(context, ForgotPasswordScreen.route());

                if (email != null) {
                  emailController.text = email as String;
                }
              },
              child: const Text('Forgot Password'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(context, RegisterScreen.route());
              },
              child: const Text('Or Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
