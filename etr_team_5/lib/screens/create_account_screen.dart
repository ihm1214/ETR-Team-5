import 'package:flutter/material.dart';
import '../auth.dart';
import '../widgets.dart';
import 'family_home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  final _child = TextEditingController();
  final _dob = TextEditingController();
  String? _nameErr, _emailErr, _passErr, _pass2Err, _childErr;
  bool _hide = true;

  void _submit() {
    setState(() {
      _nameErr = _name.text.trim().isEmpty ? 'Enter your name' : null;
      _emailErr = isValidEmail(_email.text) ? null : 'Enter a valid email address';
      _passErr = passwordProblem(_pass.text);
      _pass2Err = _pass.text == _pass2.text ? null : 'Passwords do not match';
      _childErr = _child.text.trim().isEmpty ? "Enter your child's name" : null;
    });
    if ([_nameErr, _emailErr, _passErr, _pass2Err, _childErr].any((e) => e != null)) return;
    if (!requireOnline(context)) return;

    final err = auth.signUpParent(
      name: _name.text,
      email: _email.text,
      password: _pass.text,
      childName: _child.text,
      childDob: _dob.text,
    );
    if (err != null) {
      setState(() => _emailErr = err);
      return;
    }
    // New account: the child's profile starts blank (no allergies, contacts, or forms).
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const FamilyHomeScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget gap() => const SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(title: const Text('Create account'), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const OfflineBanner(),
        const Text('Parent / guardian', style: TextStyle(fontWeight: FontWeight.bold)),
        gap(),
        TextField(controller: _name, decoration: InputDecoration(labelText: 'Your name', border: const OutlineInputBorder(), errorText: _nameErr)),
        gap(),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'Email', border: const OutlineInputBorder(), errorText: _emailErr),
        ),
        gap(),
        TextField(
          controller: _pass,
          obscureText: _hide,
          decoration: InputDecoration(
            labelText: 'Password',
            helperText: 'At least 8 characters, with a letter and a number',
            border: const OutlineInputBorder(),
            errorText: _passErr,
            suffixIcon: IconButton(
              icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _hide = !_hide),
            ),
          ),
        ),
        gap(),
        TextField(
          controller: _pass2,
          obscureText: _hide,
          decoration: InputDecoration(labelText: 'Confirm password', border: const OutlineInputBorder(), errorText: _pass2Err),
        ),
        const SizedBox(height: 24),
        const Text('Your child', style: TextStyle(fontWeight: FontWeight.bold)),
        gap(),
        TextField(controller: _child, decoration: InputDecoration(labelText: "Child's name", border: const OutlineInputBorder(), errorText: _childErr)),
        gap(),
        TextField(controller: _dob, decoration: const InputDecoration(labelText: 'Date of birth (YYYY-MM-DD, optional)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        const Text('Allergies, emergency contacts, pickup list, and forms can be added after you sign in.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        FilledButton(onPressed: _submit, child: const Text('Create account')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
        const SizedBox(height: 8),
        const Text('Prototype: use made-up names and data only.', style: TextStyle(color: Colors.grey)),
      ]),
    );
  }
}