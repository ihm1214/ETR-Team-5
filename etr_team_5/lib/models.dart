enum UserRole { family, staff, director }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.family => 'Parent',
        UserRole.staff => 'Staff',
        UserRole.director => 'Director',
      };
}

class Student {
  final String id;
  String name;
  String dob;
  List<String> allergies;
  List<String> emergencyContacts;
  List<String> approvedPickup;
  Map<String, bool> forms; // form name -> signed?
  bool present;
  String? pickedUpBy;
  String directorNote;

  Student({
    required this.id,
    required this.name,
    required this.dob,
    required this.allergies,
    required this.emergencyContacts,
    required this.approvedPickup,
    required this.forms,
    this.present = false,
    this.pickedUpBy,
    this.directorNote = '',
  });

  List<String> get missingForms =>
      forms.entries.where((e) => !e.value).map((e) => e.key).toList();
}

class ProgramEvent {
  final String id;
  String name;
  DateTime date;
  String time;
  String location;
  String description;
  DateTime deadline;
  int capacity;
  List<String> requiredForms;
  List<String> staff;
  List<String> enrolled; // student ids

  ProgramEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.deadline,
    required this.capacity,
    required this.requiredForms,
    required this.staff,
    List<String>? enrolled,
  }) : enrolled = enrolled ?? [];
}

class Message {
  final String from;
  final String text;
  final DateTime sent;
  Message({required this.from, required this.text, required this.sent});
}