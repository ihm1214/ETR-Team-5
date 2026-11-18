import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
import '../widgets.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key, this.event});
  final ProgramEvent? event; // null = create new

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late final _name = TextEditingController(text: widget.event?.name ?? '');
  late final _time = TextEditingController(text: widget.event?.time ?? '');
  late final _location = TextEditingController(text: widget.event?.location ?? '');
  late final _desc = TextEditingController(text: widget.event?.description ?? '');
  late final _cap = TextEditingController(text: '${widget.event?.capacity ?? 15}');
  late final _forms = TextEditingController(text: widget.event?.requiredForms.join(', ') ?? '');
  late final _staff = TextEditingController(text: widget.event?.staff.join(', ') ?? '');
  late DateTime _date = widget.event?.date ?? kToday;
  late DateTime _deadline = widget.event?.deadline ?? kToday;
  String? _nameErr, _capErr;

  List<String> _split(String t) => t.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<DateTime?> _pick(DateTime initial) =>
      showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2026), lastDate: DateTime(2028));

  void _save() {
    final cap = int.tryParse(_cap.text.trim());
    setState(() {
      _nameErr = _name.text.trim().isEmpty ? 'Enter an event name' : null;
      _capErr = (cap == null || cap < 1) ? 'Enter a number above 0' : null;
    });
    if (_nameErr != null || _capErr != null) return;
    if (!requireOnline(context)) return;

    final e = widget.event ??
        ProgramEvent(
          id: 'E-${db.events.length + 1}',
          name: '',
          date: _date,
          time: '',
          location: '',
          description: '',
          deadline: _deadline,
          capacity: 1,
          requiredForms: [],
          staff: [],
        );
    e
      ..name = _name.text.trim()
      ..date = _date
      ..time = _time.text.trim()
      ..location = _location.text.trim()
      ..description = _desc.text.trim()
      ..deadline = _deadline
      ..capacity = cap!
      ..requiredForms = _split(_forms.text)
      ..staff = _split(_staff.text);
    if (widget.event == null) db.events.add(e);
    db.log('Staff/Director', '${widget.event == null ? "created" : "edited"} event ${e.name}');
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this event?'),
        content: const Text('Families signed up will lose this event.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    db.events.remove(widget.event);
    db.log('Staff/Director', 'deleted event ${widget.event!.name}');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget gap() => const SizedBox(height: 12);
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'Create event' : 'Edit event'), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const OfflineBanner(),
        TextField(controller: _name, decoration: InputDecoration(labelText: 'Event name', border: const OutlineInputBorder(), errorText: _nameErr)),
        gap(),
        ListTile(
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
          title: Text('Date: ${fmtDate(_date)}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final d = await _pick(_date);
            if (d != null) setState(() => _date = d);
          },
        ),
        gap(),
        TextField(controller: _time, decoration: const InputDecoration(labelText: 'Time', border: OutlineInputBorder())),
        gap(),
        TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
        gap(),
        TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Program description', border: OutlineInputBorder())),
        gap(),
        ListTile(
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
          title: Text('Sign-up deadline: ${fmtDate(_deadline)}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final d = await _pick(_deadline);
            if (d != null) setState(() => _deadline = d);
          },
        ),
        gap(),
        TextField(
          controller: _cap,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Capacity', border: const OutlineInputBorder(), errorText: _capErr),
        ),
        gap(),
        TextField(controller: _forms, decoration: const InputDecoration(labelText: 'Required forms (comma separated)', border: OutlineInputBorder())),
        gap(),
        TextField(controller: _staff, decoration: const InputDecoration(labelText: 'Staff list (comma separated)', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
          const SizedBox(width: 12),
          Expanded(child: FilledButton(onPressed: _save, child: const Text('Save'))),
        ]),
        if (widget.event != null)
          TextButton(
            onPressed: _delete,
            child: const Text('Delete event', style: TextStyle(color: Colors.red)),
          ),
      ]),
    );
  }
}