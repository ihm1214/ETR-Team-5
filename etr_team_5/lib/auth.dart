import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'models.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Returns a problem message, or null if the password is strong enough.
String? passwordProblem(String p) {
  if (p.length < 8) return 'Use at least 8 characters';
  if (!RegExp(r'[A-Za-z]').hasMatch(p) || !RegExp(r'\d').hasMatch(p)) {
    return 'Include at least one letter and one number';
  }
  return null;
}

bool isValidEmail(String e) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e.trim());

class AuthService {
  Account? current;
  String? selectedChildId;

  String _newSalt() {
    final r = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  /// Prototype only. A real server should use bcrypt or Argon2.
  String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  List<Student> get children {
    final a = current;
    if (a == null) return [];
    return db.students.where((s) => a.childIds.contains(s.id)).toList();
  }

  Student _newStudent(String name, String dob) => Student(
        id: 'S-${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        dob: dob.trim().isEmpty ? 'Not provided' : dob.trim(),
        allergies: [],
        emergencyContacts: [],
        approvedPickup: [],
        forms: {'Photo consent': false, 'Pickup authorization': false, 'Medical form': false},
      );

  /// Creates a parent account plus a blank profile for their child.
  /// Returns an error message, or null on success.
  String? signUpParent({
    required String name,
    required String email,
    required String password,
    required String childName,
    required String childDob,
  }) {
    final e = email.trim().toLowerCase();
    if (db.accounts.any((a) => a.email == e)) {
      return 'An account with this email already exists';
    }
    final salt = _newSalt();
    final child = _newStudent(childName, childDob);
    db.students.add(child);
    final acct = Account(
      email: e,
      name: name.trim(),
      role: UserRole.family,
      salt: salt,
      hash: hashPassword(password, salt),
      childIds: [child.id],
    );
    db.accounts.add(acct);
    current = acct;
    selectedChildId = child.id;
    db.log('Parent', 'created an account');
    return null;
  }

  /// Returns an error message, or null on success.
  String? logIn(UserRole role, String email, String password) {
    const bad = 'Incorrect email or password';
    final e = email.trim().toLowerCase();
    final matches = db.accounts.where((a) => a.email == e).toList();
    if (matches.isEmpty) return bad;
    final a = matches.first;
    // The ROLE comes from the stored account, never from the button tapped.
    if (a.hash != hashPassword(password, a.salt) || a.role != role) return bad;
    current = a;
    selectedChildId = a.childIds.isEmpty ? null : a.childIds.first;
    db.log(role.label, 'logged in');
    return null;
  }

  void addChild(String name, String dob) {
    final c = _newStudent(name, dob);
    db.students.add(c);
    current!.childIds.add(c.id);
    selectedChildId = c.id;
    db.log('Parent', 'added another child');
  }

  void logout() {
    final a = current;
    if (a != null) db.log(a.role.label, 'logged out');
    current = null;
    selectedChildId = null;
  }
}

final AuthService auth = AuthService();