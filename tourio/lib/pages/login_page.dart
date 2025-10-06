import 'package:flutter/material.dart';
import '../widgets/slideshow_background.dart';
import '../widgets/tourio_logo.dart';
import '../widgets/frost_button.dart';
import '../widgets/obscured_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const fieldWidth = 320.0;

    return Scaffold(
      body: SlideshowBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const TourioLogo(width: 260),
                  const SizedBox(height: 150),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: fieldWidth),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Username/Email'),
                        ),
                        const SizedBox(height: 12),
                        ObscuredTextField(controller: _pwCtrl, label: 'Password'),
                        const SizedBox(height: 18),
                        FrostButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                          label: 'LOG IN',
                        ),
                        const SizedBox(height: 12),
                        FrostButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          label: 'SIGN UP',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}