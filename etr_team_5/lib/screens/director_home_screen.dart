import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
import '../widgets.dart';
import 'edit_event_screen.dart';
import 'role_select_screen.dart';

class DirectorHomeScreen extends StatefulWidget {
  const DirectorHomeScreen({super.key});

  @override
  State<DirectorHomeScreen> createState() => _DirectorHomeScreenState();
}

class _DirectorHomeScreenState extends State<DirectorHomeScreen> {
  Future<void> _go(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final total = db.students.length;
    final present = db.students.where((s) => s.present).length;
    final missing = db.students.where((s) => s.missingForms.isNotEmpty).toList();
    final formsDone = db.students.fold<int>(0, (a, s) => a + s.forms.values.where((v) => v).length);
    final formsAll = db.students.fold<int>(0, (a, s) => a + s.forms.length);
    final pct = formsAll == 0 ? 0 : (100 * formsDone / formsAll).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Program director'), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const OfflineBanner(),
        const SectionTitle('Enrollment'),
        Row(children: [
          Expanded(child: Card(child: ListTile(title: Text('$total'), subtitle: const Text('Students')))),
          Expanded(child: Card(child: ListTile(title: Text('${db.events.length}'), subtitle: const Text('Events')))),
        ]),
        const SectionTitle('Alerts requiring action'),
        if (missing.isEmpty) const Text('Nothing needs action.'),
        for (final s in missing)
          Card(
            color: Colors.orange.shade50,
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(s.name),
              subtitle: Text('Missing: ${s.missingForms.join(", ")}'),
            ),
          ),
        const SectionTitle('Programs & events'),
        for (final e in db.events)
          Card(
            child: ListTile(
              title: Text(e.name),
              subtitle: Text('${fmtDate(e.date)} · ${e.enrolled.length}/${e.capacity} enrolled'),
              trailing: const Icon(Icons.edit),
              onTap: () => _go(EditEventScreen(event: e)),
            ),
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add event'),
          onPressed: () => _go(const EditEventScreen()),
        ),
        const SectionTitle('Data reports'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Checked in today: $present of $total'),
              const SizedBox(height: 4),
              Text('Form completion: $pct%'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: pct / 100),
            ]),
          ),
        ),
        const SectionTitle('Student profiles'),
        for (final s in db.students)
          StudentCard(
            student: s,
            subtitle: s.directorNote.isEmpty ? null : 'Note: ${s.directorNote}',
            onTap: () async {
              showStudentDetails(context, s, viewer: UserRole.director);
            },
          ),
        const SectionTitle('Messages'),
        for (final m in db.messages) Card(child: ListTile(title: Text(m.from), subtitle: Text(m.text))),
        OutlinedButton.icon(
          icon: const Icon(Icons.message),
          label: const Text('Send message to all'),
          onPressed: () async {
            await showMessageDialog(context, 'Director');
            if (mounted) setState(() {});
          },
        ),
        const SectionTitle('Audit log'),
        if (db.auditLog.isEmpty) const Text('No activity yet. Try logging in or editing something.'),
        for (final line in db.auditLog.take(10)) Text('• $line', style: const TextStyle(fontSize: 12)),
        TextButton(onPressed: () => signOut(context), child: const Text('Sign out')),
      ]),
    );
  }
}