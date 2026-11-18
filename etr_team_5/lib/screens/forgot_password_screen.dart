import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _newPass = TextEditingController();
  int _step = 0; // 0 email, 1 code + new password, 2 done
  String? _err;
  String? _info;

  void _sendCode() {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim())) {
      setState(() => _err = 'Enter a valid email address');
      return;
    }
    setState(() {
      _err = null;
      _step = 1;
      _info = 'Code sent (prototype code: 123456). It expires in 10 minutes.';
    });
  }

  void _reset() {
    if (_code.text.trim() != '123456') {
      setState(() => _err = 'Incorrect or expired code');
    } else if (_newPass.text.length < 8) {
      setState(() => _err = 'Password must be at least 8 characters');
    } else {
      setState(() {
        _err = null;
        _step = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot your password?')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_step == 0) ...[
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email', border: const OutlineInputBorder(), errorText: _err),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _sendCode, child: const Text('Send code')),
          ],
          if (_step == 1) ...[
            if (_info != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_info!)),
            TextField(
              controller: _code,
              decoration: InputDecoration(labelText: 'One-time code', border: const OutlineInputBorder(), errorText: _err),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _reset, child: const Text('Set new password')),
            TextButton(
              onPressed: () => setState(() => _info = 'New code sent (prototype code: 123456).'),
              child: const Text('Resend code'),
            ),
          ],
          if (_step == 2) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 12),
            const Text('Password updated. You can log in now.', textAlign: TextAlign.center),
          ],
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to login')),
        ]),
      ),
    );
  }
}