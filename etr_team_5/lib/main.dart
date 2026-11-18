import 'dart:async';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'mock_data.dart';
import 'screens/role_select_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.init();
  runApp(const YouthApp());
}

class YouthApp extends StatefulWidget {
  const YouthApp({super.key});

  @override
  State<YouthApp> createState() => _YouthAppState();
}

class _YouthAppState extends State<YouthApp> {
  // Auto logout after inactivity. Set to Duration(seconds: 20) to demo it.
  static const _idle = Duration(minutes: 5);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _timer?.cancel();
    _timer = Timer(_idle, _timeout);
  }

  void _timeout() {
    if (auth.current == null) return;
    auth.logout();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      (r) => false,
    );
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('You were signed out after being inactive.')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Youth Program App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        builder: (context, child) => Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _reset(),
          child: child!,
        ),
        home: const RoleSelectScreen(),
      );
}