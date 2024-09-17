import 'package:flutter/material.dart';
import 'package:udetxen/features/home/screens/home_screen.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';
import 'package:udetxen/shared/widgets/layouts/unauthenticated_layout.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => const UnauthenticatedLayout(initialScreen: 1),
    );
  }

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final authService = getIt<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String errorMessage = '';

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                final response = await authService.registerWithEmail(
                  emailController.text,
                  passwordController.text,
                );
                await response.on(
                    onFailure: (failure) =>
                        _showError(failure.userFriendlyMessage),
                    onSuccess: (_) {
                      Navigator.pop(context);
                      Navigator.pushReplacement(context, HomeScreen.route());
                    });
              },
              child: const Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Or Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
