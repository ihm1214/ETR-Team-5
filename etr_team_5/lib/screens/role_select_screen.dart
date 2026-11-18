import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets.dart';
import 'login_screen.dart';

void signOut(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
    (r) => false,
  );
}

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User'), actions: const [OnlineToggle()]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const OfflineBanner(),
            const Spacer(),
            for (final r in UserRole.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LoginScreen(role: r)),
                    ),
                    child: Text('${r.label} login'),
                  ),
                ),
              ),
            const Spacer(),
            const Text('Customer support: support@example.org · 555-0100'),
            const Text('Version 0.0.1'),
          ]),
        ),
      ),
    );
  }
}