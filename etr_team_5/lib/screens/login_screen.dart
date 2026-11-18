import 'package:flutter/material.dart';
import '../auth.dart';
import '../models.dart';
import '../widgets.dart';
import 'create_account_screen.dart';
import 'director_home_screen.dart';
import 'family_home_screen.dart';
import 'forgot_password_screen.dart';
import 'staff_home_screen.dart';

Widget homeFor(UserRole r) => switch (r) {
      UserRole.family => const FamilyHomeScreen(),
      UserRole.staff => const StaffHomeScreen(),
      UserRole.director => const DirectorHomeScreen(),
    };

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role});
  final UserRole role;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String? _emailErr, _passErr, _loginErr;
  bool _hide = true;

  void _login() {
    setState(() {
      _loginErr = null;
      _emailErr = isValidEmail(_email.text) ? null : 'Enter a valid email address';
      _passErr = _pass.text.isEmpty ? 'Enter your password' : null;
    });
    if (_emailErr != null || _passErr != null) return;
    if (!requireOnline(context)) return;

    final err = auth.logIn(widget.role, _email.text, _pass.text);
    if (err != null) {
      setState(() => _loginErr = err);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => homeFor(widget.role)),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role.label} login'), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const OfflineBanner(),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'Username / email', border: const OutlineInputBorder(), errorText: _emailErr),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pass,
          obscureText: _hide,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            errorText: _passErr,
            suffixIcon: IconButton(
              icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _hide = !_hide),
            ),
          ),
        ),
        if (_loginErr != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_loginErr!, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
            child: const Text('Forgot password? Use a one-time code'),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _login, child: const Text('Log in')),
        if (widget.role == UserRole.family) ...[
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateAccountScreen())),
            child: const Text('Create account'),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
        const SizedBox(height: 16),
        Text(
          switch (widget.role) {
            UserRole.family => 'Demo: parent@demo.org / Parent1234!  (or create an account)',
            UserRole.staff => 'Demo: staff@demo.org / Staff1234!',
            UserRole.director => 'Demo: director@demo.org / Director1234!',
          },
          style: const TextStyle(color: Colors.grey),
        ),
      ]),
    );
  }
}