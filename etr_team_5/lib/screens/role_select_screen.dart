import 'package:flutter/material.dart';
import '../auth.dart';
import '../mock_data.dart';
import '../models.dart';
import '../widgets.dart';
import 'login_screen.dart';

void signOut(BuildContext context) {
  auth.logout();
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
            TextButton(
              onPressed: () async {
                await db.resetDemo();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo data reset')),
                  );
                }
              },
              child: const Text('Reset demo data'),
            ),
            const Text('Customer support: support@example.org · 555-0100'),
            const Text('Version 0.0.2'),
          ]),
        ),
      ),
    );
  }
}