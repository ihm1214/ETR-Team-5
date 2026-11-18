import 'package:flutter/material.dart';
import '../auth.dart';
import '../mock_data.dart';
import '../widgets.dart';
import 'edit_student_screen.dart';
import 'my_events_screen.dart';
import 'role_select_screen.dart';

class FamilyHomeScreen extends StatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> {
  DateTime _selected = kToday;

  Future<void> _go(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  Future<void> _addChild() async {
    final name = TextEditingController();
    final dob = TextEditingController();
    String? err;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Add another child'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: InputDecoration(labelText: "Child's name", errorText: err)),
            TextField(controller: dob, decoration: const InputDecoration(labelText: 'Date of birth (YYYY-MM-DD)')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty) {
                  setD(() => err = 'Enter a name');
                } else {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    if (!requireOnline(context)) return;
    auth.addChild(name.text, dob.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = db.myChild;
    final kids = auth.children;
    final mine = db.events.where((e) => e.enrolled.contains(s.id)).toList();
    final dayEvents = mine.where((e) => DateUtils.isSameDay(e.date, _selected)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(s.name), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const OfflineBanner(),
        Text('Signed in as ${auth.current?.name ?? ""}', style: const TextStyle(color: Colors.grey)),
        if (kids.length > 1)
          DropdownButton<String>(
            isExpanded: true,
            value: s.id,
            items: [for (final c in kids) DropdownMenuItem(value: c.id, child: Text(c.name))],
            onChanged: (v) => setState(() => auth.selectedChildId = v),
          ),
        FormProgressBanner(student: s),
        const SectionTitle('Current schedule'),
        CalendarDatePicker(
          initialDate: kToday,
          firstDate: DateTime(2026),
          lastDate: DateTime(2027, 12, 31),
          onDateChanged: (d) => setState(() => _selected = d),
        ),
        if (dayEvents.isEmpty)
          Text('No events on ${fmtDate(_selected)}')
        else
          for (final e in dayEvents)
            Card(child: ListTile(title: Text(e.name), subtitle: Text('${e.time} · ${e.location}'))),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.event),
          label: const Text('My events'),
          onPressed: () => _go(const MyEventsScreen()),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit student information'),
          onPressed: () => _go(const EditStudentScreen()),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text('Add another child'),
          onPressed: _addChild,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.message),
          label: const Text('Message staff'),
          onPressed: () async {
            await showMessageDialog(context, 'Parent of ${s.name}');
            if (mounted) setState(() {});
          },
        ),
        TextButton(onPressed: () => signOut(context), child: const Text('Sign out')),
      ]),
    );
  }
}