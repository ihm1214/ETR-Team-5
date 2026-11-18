import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'auth.dart';
import 'models.dart';
import 'storage.dart';

/// "Today" for the prototype, so the demo always has events today.
final DateTime kToday = DateTime(2026, 11, 18);

/// Demo logins (made-up):
///   parent@demo.org    / Parent1234!
///   staff@demo.org     / Staff1234!
///   director@demo.org  / Director1234!
class MockDb {
  final ValueNotifier<bool> online = ValueNotifier<bool>(true);

  final List<Student> students = [];
  final List<ProgramEvent> events = [];
  final List<Message> messages = [];
  final List<String> auditLog = [];
  final List<Account> accounts = [];

  /// The currently selected child of the logged-in parent.
  Student get myChild {
    final kids = auth.children;
    return kids.firstWhere((s) => s.id == auth.selectedChildId, orElse: () => kids.first);
  }

  Future<void> init() async {
    await Storage.init();
    final raw = Storage.read('appData');
    if (raw == null) {
      _seed();
      await save();
      return;
    }
    try {
      _load(raw);
    } catch (_) {
      _seed();
      await save();
    }
  }

  Future<void> save() => Storage.write(
        'appData',
        jsonEncode({
          'students': students.map((s) => s.toJson()).toList(),
          'events': events.map((e) => e.toJson()).toList(),
          'messages': messages.map((m) => m.toJson()).toList(),
          'auditLog': auditLog,
          'accounts': accounts.map((a) => a.toJson()).toList(),
        }),
      );

  /// Wipes saved data and goes back to the made-up demo data.
  Future<void> resetDemo() async {
    auth.current = null;
    auth.selectedChildId = null;
    _seed();
    await save();
  }

  void log(String who, String action) {
    final n = DateTime.now().toString().substring(11, 16);
    auditLog.insert(0, '$n  $who: $action');
    save(); // every logged action also saves the data
  }

  void _load(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    students
      ..clear()
      ..addAll((j['students'] as List).map((e) => Student.fromJson(e as Map<String, dynamic>)));
    events
      ..clear()
      ..addAll((j['events'] as List).map((e) => ProgramEvent.fromJson(e as Map<String, dynamic>)));
    messages
      ..clear()
      ..addAll((j['messages'] as List).map((e) => Message.fromJson(e as Map<String, dynamic>)));
    auditLog
      ..clear()
      ..addAll(List<String>.from(j['auditLog'] as List));
    accounts
      ..clear()
      ..addAll((j['accounts'] as List).map((e) => Account.fromJson(e as Map<String, dynamic>)));
  }

  void _seed() {
    students
      ..clear()
      ..addAll([
        Student(
          id: 'S-0001',
          name: 'John Doe',
          dob: '2014-05-12',
          allergies: ['Peanut'],
          emergencyContacts: ['Mother Doe – 5550101234', 'Father Doe – 5550105678'],
          approvedPickup: ['Mother Doe', 'Father Doe'],
          forms: {'Photo consent': true, 'Pickup authorization': true, 'Medical form': false},
        ),
        Student(
          id: 'S-0002',
          name: 'Jane Roe',
          dob: '2013-09-03',
          allergies: [],
          emergencyContacts: ['Guardian Roe – 5550102222'],
          approvedPickup: ['Guardian Roe', 'Grandparent Roe'],
          forms: {'Photo consent': true, 'Pickup authorization': true, 'Medical form': true},
        ),
        Student(
          id: 'S-0003',
          name: 'Sam Poe',
          dob: '2015-01-27',
          allergies: ['Bee sting', 'Dairy'],
          emergencyContacts: ['Parent Poe – 5550103333'],
          approvedPickup: ['Parent Poe'],
          forms: {'Photo consent': false, 'Pickup authorization': true, 'Medical form': true},
        ),
      ]);

    events
      ..clear()
      ..addAll([
        ProgramEvent(
          id: 'E-1',
          name: 'Math Club',
          date: DateTime(2026, 11, 18),
          time: '3:30–5:00 PM',
          location: 'Room 12',
          description: 'After-school math games and homework help.',
          deadline: DateTime(2026, 11, 10),
          capacity: 12,
          requiredForms: ['Photo consent'],
          staff: ['Instructor 1'],
          enrolled: ['S-0001', 'S-0002'],
        ),
        ProgramEvent(
          id: 'E-2',
          name: 'Weekend Football',
          date: DateTime(2026, 11, 21),
          time: '10:00 AM–12:00 PM',
          location: 'Town Field',
          description: 'Beginner-friendly football skills and scrimmage.',
          deadline: DateTime(2026, 11, 19),
          capacity: 20,
          requiredForms: ['Medical form'],
          staff: ['Instructor 2'],
          enrolled: ['S-0002', 'S-0003'],
        ),
        ProgramEvent(
          id: 'E-3',
          name: 'Winter Break Camp',
          date: DateTime(2026, 12, 28),
          time: '9:00 AM–3:00 PM',
          location: 'Community Center',
          description: 'Full-day camp with crafts, games, and sports.',
          deadline: DateTime(2026, 12, 10),
          capacity: 15,
          requiredForms: ['Photo consent', 'Medical form'],
          staff: ['Instructor 1', 'Instructor 2'],
        ),
      ]);

    messages
      ..clear()
      ..add(Message(from: 'Mother Doe', text: 'Will the Math Club end on time today?', sent: DateTime(2026, 11, 18)));

    auditLog.clear();

    Account make(String email, String name, UserRole role, String pw, [List<String>? kids]) => Account(
          email: email,
          name: name,
          role: role,
          salt: 'demosalt',
          hash: auth.hashPassword(pw, 'demosalt'),
          childIds: kids,
        );

    accounts
      ..clear()
      ..addAll([
        make('parent@demo.org', 'Mother Doe', UserRole.family, 'Parent1234!', ['S-0001']),
        make('staff@demo.org', 'Instructor 1', UserRole.staff, 'Staff1234!'),
        make('director@demo.org', 'Director 1', UserRole.director, 'Director1234!'),
      ]);
  }
}

final MockDb db = MockDb();