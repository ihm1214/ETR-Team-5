import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
import '../widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required this.event});
  final ProgramEvent event;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _q = '';

  void _snack(String msg, VoidCallback onUndo) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 30), // 30-second undo window
        content: Text(msg),
        action: SnackBarAction(label: 'Undo', onPressed: onUndo),
      ));
  }

  void _checkIn(Student s, bool value) {
    setState(() => s.present = value);
    db.log('Instructor', '${value ? "checked in" : "marked absent"} ${s.name}');
    _snack('${s.name} ${value ? "checked in" : "marked absent"}', () {
      s.present = !value;
      db.log('Instructor', 'undid change for ${s.name}');
      if (mounted) setState(() {});
    });
  }

  Future<void> _pickup(Student s) async {
    String? choice;
    var idOk = false;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final notOnList = choice == 'OTHER';
          return AlertDialog(
            title: Text('Pickup: ${s.name}'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (s.allergies.isNotEmpty) Wrap(spacing: 6, children: [for (final a in s.allergies) AlertBadge(a)]),
                const SizedBox(height: 8),
                const Text('Who is picking up?', style: TextStyle(fontWeight: FontWeight.bold)),
                for (final p in [...s.approvedPickup, 'OTHER'])
                  ListTile(
                    dense: true,
                    selected: choice == p,
                    leading: Icon(choice == p ? Icons.check_circle : Icons.circle_outlined),
                    title: Text(p == 'OTHER' ? 'Someone else (not on list)' : p),
                    onTap: () => setD(() => choice = p),
                  ),
                if (notOnList)
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red.shade50,
                    child: const Text(
                      'STOP: this person is not approved. Do NOT release the child. Call a guardian or the director.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Photo ID checked'),
                    value: idOk,
                    onChanged: (v) => setD(() => idOk = v ?? false),
                  ),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: (choice != null && !notOnList && idOk) ? () => Navigator.pop(ctx, choice) : null,
                child: const Text('Confirm sign-out'),
              ),
            ],
          );
        },
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      s.pickedUpBy = result;
      s.present = false;
    });
    db.log('Instructor', '${s.name} picked up by $result (ID checked)');
    _snack('${s.name} signed out to $result', () {
      s.pickedUpBy = null;
      s.present = true;
      db.log('Instructor', 'undid pickup for ${s.name}');
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final roster = db.students
        .where((s) => widget.event.enrolled.contains(s.id) && s.name.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.event.name} attendance'), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const OfflineBanner(),
        TextField(
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search students', border: OutlineInputBorder()),
          onChanged: (v) => setState(() => _q = v),
        ),
        const SizedBox(height: 12),
        for (final s in roster)
          StudentCard(
            student: s,
            subtitle: s.pickedUpBy != null ? 'Picked up by ${s.pickedUpBy}' : (s.present ? 'Present' : 'Not checked in'),
            onTap: () => showStudentDetails(
              context,
              s,
              viewer: UserRole.staff,
              onPickup: s.pickedUpBy == null ? () => _pickup(s) : null,
            ),
            trailing: s.pickedUpBy != null
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Switch(value: s.present, onChanged: (v) => _checkIn(s, v)),
          ),
        if (roster.isEmpty) const Text('No students found.'),
      ]),
    );
  }
}