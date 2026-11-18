import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../widgets.dart';
import 'attendance_screen.dart';
import 'edit_event_screen.dart';
import 'role_select_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  Future<void> _go(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final todays = db.events.where((e) => DateUtils.isSameDay(e.date, kToday)).toList();
    final ids = {for (final e in todays) ...e.enrolled};
    final alertKids = db.students.where((s) => ids.contains(s.id) && s.allergies.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Staff'), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const OfflineBanner(),
        const SectionTitle("Today's program"),
        if (todays.isEmpty) const Text('No programs today.'),
        for (final e in todays)
          Card(
            child: ListTile(
              title: Text(e.name),
              subtitle: Text('${e.time} · ${e.location}\n${e.enrolled.length} students'),
              isThreeLine: true,
              trailing: const Text('Roster'),
              onTap: () => _go(AttendanceScreen(event: e)),
            ),
          ),
        const SectionTitle('Alerts'),
        if (alertKids.isEmpty) const Text('No alerts today.'),
        for (final s in alertKids)
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.warning_amber, color: Colors.red),
              title: Text(s.name),
              subtitle: Text('Allergy: ${s.allergies.join(", ")}'),
            ),
          ),
        const SectionTitle('Messages from families'),
        if (db.messages.isEmpty) const Text('No messages.'),
        for (final m in db.messages)
          Card(child: ListTile(title: Text(m.from), subtitle: Text(m.text))),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.message),
          label: const Text('Message families'),
          onPressed: () async {
            await showMessageDialog(context, 'Staff');
            if (mounted) setState(() {});
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Create event'),
          onPressed: () => _go(const EditEventScreen()),
        ),
        TextButton(onPressed: () => signOut(context), child: const Text('Sign out')),
      ]),
    );
  }
}