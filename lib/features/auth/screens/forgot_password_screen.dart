import 'package:flutter/material.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';
import 'package:udetxen/shared/utils/notification_util.dart';
import 'package:provider/provider.dart';
import 'package:udetxen/shared/widgets/layouts/unauthenticated_layout.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => const UnauthenticatedLayout(initialScreen: 2),
    );
  }

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String errorMessage = '';
  final emailController = TextEditingController();

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
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
            ElevatedButton(
              onPressed: () async {
                final response = await authService
                    .sendPasswordResetEmail(emailController.text);
                if (response.failure != null) {
                  _showError(response.failure!.userFriendlyMessage);
                } else if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    LoginScreen.route(email: emailController.text),
                  );

                  final notificationUtil =
                      Provider.of<NotificationUtil>(context, listen: false);

                  await notificationUtil.showNotification(
                    title: 'Password Reset Email Sent',
                    body:
                        'A password reset email has been sent to ${emailController.text}',
                    payload: 'password_reset',
                  );
                }
              },
              child: const Text('Send Reset Email'),
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
