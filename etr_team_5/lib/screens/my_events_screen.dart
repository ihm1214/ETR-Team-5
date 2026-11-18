import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
import '../widgets.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final _s = db.myChild;

  void _toggle(ProgramEvent e, bool join) {
    if (!requireOnline(context)) return;
    if (join && e.enrolled.length >= e.capacity) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This event is full')));
      return;
    }
    setState(() => join ? e.enrolled.add(_s.id) : e.enrolled.remove(_s.id));
    db.log('Parent', '${join ? "signed up for" : "withdrew from"} ${e.name}');
  }

  @override
  Widget build(BuildContext context) {
    final mine = db.events.where((e) => e.enrolled.contains(_s.id)).toList();
    final others = db.events.where((e) => !e.enrolled.contains(_s.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My events'), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const OfflineBanner(),
        const SectionTitle('Signed up'),
        if (mine.isEmpty) const Text('Not signed up for any events yet.'),
        for (final e in mine)
          Card(
            child: ListTile(
              title: Text(e.name),
              subtitle: Text('${fmtDate(e.date)} · ${e.time}\n${e.location}'),
              isThreeLine: true,
              trailing: TextButton(onPressed: () => _toggle(e, false), child: const Text('Withdraw')),
            ),
          ),
        const SectionTitle('Other events'),
        for (final e in others)
          Card(
            child: ListTile(
              title: Text(e.name),
              subtitle: Text('${fmtDate(e.date)} · Sign up by ${fmtDate(e.deadline)}\n'
                  '${e.enrolled.length}/${e.capacity} spots filled'),
              isThreeLine: true,
              trailing: e.deadline.isBefore(kToday)
                  ? const Text('Closed', style: TextStyle(color: Colors.red))
                  : FilledButton(onPressed: () => _toggle(e, true), child: const Text('Sign up')),
            ),
          ),
      ]),
    );
  }
}