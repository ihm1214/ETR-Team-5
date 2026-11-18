import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
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
  String? _emailErr, _passErr;
  bool _hide = true;

  void _login() {
    setState(() {
      _emailErr = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim())
          ? null
          : 'Enter a valid email address';
      _passErr = _pass.text.length >= 8 ? null : 'Password must be at least 8 characters';
    });
    if (_emailErr != null || _passErr != null) return;
    db.log(widget.role.label, 'logged in');
    // In a real app, the SERVER decides the role from the account.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => homeFor(widget.role)),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role.label} login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
          const SizedBox(height: 16),
          const Text('Prototype: any valid email and an 8+ character password works.',
              style: TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}