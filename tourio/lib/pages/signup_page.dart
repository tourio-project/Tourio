
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/slideshow_background.dart';
import '../widgets/tourio_logo.dart';
import '../widgets/frost_button.dart';
import '../widgets/obscured_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _dayCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _dayNode = FocusNode();
  final _monthNode = FocusNode();
  final _yearNode = FocusNode();
  String? _dobError;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    _dayNode.dispose();
    _monthNode.dispose();
    _yearNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validateUsername(String? v) {
    if (v == null || v.trim().isEmpty) return 'Username is required';
    if (v.trim().length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    final hasMin = v.length >= 8;
    final hasSymbol = RegExp(r'[!@#\$%^&*()_\+\-\=\[\]{};:"\\|,.<>\/?~`]').hasMatch(v);
    if (!hasMin) return 'Password must be at least 8 characters';
    if (!hasSymbol) return 'Password must contain at least one symbol';
    return null;
  }

  bool _isValidDate(int y, int m, int d) {
    try {
      final dt = DateTime(y, m, d);
      return dt.year == y && dt.month == m && dt.day == d;
    } catch (_) {
      return false;
    }
  }

  bool _is18OrOlder(int y, int m, int d) {
    final now = DateTime.now();
    int age = now.year - y;
    if (now.month < m || (now.month == m && now.day < d)) age--;
    return age >= 18;
  }

  Future<void> _submit() async {
    setState(() => _dobError = null);
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final d = int.tryParse(_dayCtrl.text);
    final m = int.tryParse(_monthCtrl.text);
    final y = int.tryParse(_yearCtrl.text);

    if (d == null || m == null || y == null) {
      setState(() => _dobError = 'Enter your full date of birth');
      return;
    }
    if (!_isValidDate(y, m, d)) {
      setState(() => _dobError = 'Enter a valid date (DD/MM/YYYY)');
      return;
    }
    if (!_is18OrOlder(y, m, d)) {
      setState(() => _dobError = 'You must be 18 or older to sign up');
      return;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created!')));
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    const fieldWidth = 320.0;
    const boxH = 56.0;

    InputDecoration dobDeco(String hint) =>
        InputDecoration(hintText: hint, counterText: '');

    return Scaffold(
      body: SlideshowBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // <- Back arrow added here
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const TourioLogo(width: 250),
                    const SizedBox(height: 150),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: fieldWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _usernameCtrl,
                            decoration: const InputDecoration(labelText: 'Username'),
                            validator: _validateUsername,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: _validateEmail,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          ObscuredTextField(
                            controller: _pwCtrl,
                            label: 'Password',
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Date of Birth',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              SizedBox(
                                width: 70,
                                height: boxH,
                                child: TextField(
                                  controller: _dayCtrl,
                                  focusNode: _dayNode,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  decoration: dobDeco('DD'),
                                  onChanged: (v) {
                                    if (v.length == 2) {
                                      FocusScope.of(context).requestFocus(_monthNode);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 70,
                                height: boxH,
                                child: TextField(
                                  controller: _monthCtrl,
                                  focusNode: _monthNode,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  decoration: dobDeco('MM'),
                                  onChanged: (v) {
                                    if (v.length == 2) {
                                      FocusScope.of(context).requestFocus(_yearNode);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 110,
                                height: boxH,
                                child: TextField(
                                  controller: _yearCtrl,
                                  focusNode: _yearNode,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  decoration: dobDeco('YYYY'),
                                ),
                              ),
                            ],
                          ),
                          if (_dobError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _dobError!,
                              style: const TextStyle(color: Color(0xFFFFE082), fontSize: 12.5),
                            ),
                          ],
                          const SizedBox(height: 18),
                          FrostButton(
                            onPressed: _submit,
                            label: 'CREATE ACCOUNT',
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
      ),
    );
  }
}
