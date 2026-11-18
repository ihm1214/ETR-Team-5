enum UserRole { family, staff, director }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.family => 'Parent',
        UserRole.staff => 'Staff',
        UserRole.director => 'Director',
      };
}

class Account {
  final String email;
  final String name;
  final UserRole role;
  final String salt;
  final String hash;
  final List<String> childIds;

  Account({
    required this.email,
    required this.name,
    required this.role,
    required this.salt,
    required this.hash,
    List<String>? childIds,
  }) : childIds = childIds ?? [];

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'role': role.name,
        'salt': salt,
        'hash': hash,
        'childIds': childIds,
      };

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        email: j['email'] as String,
        name: j['name'] as String,
        role: UserRole.values.byName(j['role'] as String),
        salt: j['salt'] as String,
        hash: j['hash'] as String,
        childIds: List<String>.from(j['childIds'] as List),
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dob': dob,
        'allergies': allergies,
        'emergencyContacts': emergencyContacts,
        'approvedPickup': approvedPickup,
        'forms': forms,
        'present': present,
        'pickedUpBy': pickedUpBy,
        'directorNote': directorNote,
      };

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        id: j['id'] as String,
        name: j['name'] as String,
        dob: j['dob'] as String,
        allergies: List<String>.from(j['allergies'] as List),
        emergencyContacts: List<String>.from(j['emergencyContacts'] as List),
        approvedPickup: List<String>.from(j['approvedPickup'] as List),
        forms: Map<String, bool>.from(j['forms'] as Map),
        present: (j['present'] as bool?) ?? false,
        pickedUpBy: j['pickedUpBy'] as String?,
        directorNote: (j['directorNote'] as String?) ?? '',
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'time': time,
        'location': location,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'capacity': capacity,
        'requiredForms': requiredForms,
        'staff': staff,
        'enrolled': enrolled,
      };

  factory ProgramEvent.fromJson(Map<String, dynamic> j) => ProgramEvent(
        id: j['id'] as String,
        name: j['name'] as String,
        date: DateTime.parse(j['date'] as String),
        time: j['time'] as String,
        location: j['location'] as String,
        description: j['description'] as String,
        deadline: DateTime.parse(j['deadline'] as String),
        capacity: j['capacity'] as int,
        requiredForms: List<String>.from(j['requiredForms'] as List),
        staff: List<String>.from(j['staff'] as List),
        enrolled: List<String>.from(j['enrolled'] as List),
      );
}

class Message {
  final String from;
  final String text;
  final DateTime sent;
  Message({required this.from, required this.text, required this.sent});

  Map<String, dynamic> toJson() => {'from': from, 'text': text, 'sent': sent.toIso8601String()};

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        from: j['from'] as String,
        text: j['text'] as String,
        sent: DateTime.parse(j['sent'] as String),
      );
}