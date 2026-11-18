import 'package:flutter/material.dart';
import 'screens/role_select_screen.dart';

void main() => runApp(const YouthApp());

class YouthApp extends StatelessWidget {
  const YouthApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Youth Program App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const RoleSelectScreen(),
      );
}