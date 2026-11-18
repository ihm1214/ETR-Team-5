import 'package:flutter/foundation.dart';
import 'models.dart';

/// "Today" for the prototype, so the demo always has events today.
final DateTime kToday = DateTime(2026, 11, 18);

class MockDb {
  final ValueNotifier<bool> online = ValueNotifier<bool>(true);

  final List<Student> students = [
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
  ];

  final List<ProgramEvent> events = [
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
  ];

  final List<Message> messages = [
    Message(
      from: 'Mother Doe',
      text: 'Will the Math Club end on time today?',
      sent: DateTime(2026, 11, 18),
    ),
  ];

  final List<String> auditLog = [];

  /// The logged-in parent's child in the prototype.
  Student get myChild => students.first;

  void log(String who, String action) {
    final n = DateTime.now().toString().substring(11, 16);
    auditLog.insert(0, '$n  $who: $action');
  }
}

final MockDb db = MockDb();