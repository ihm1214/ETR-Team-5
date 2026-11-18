import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../widgets.dart';

Future<String?> _askPerson(BuildContext context, {required bool needPhone}) {
  final name = TextEditingController();
  final phone = TextEditingController();
  String? nameErr, phoneErr;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        title: Text(needPhone ? 'Add emergency contact' : 'Add approved pickup person'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: InputDecoration(labelText: 'Name', errorText: nameErr)),
          if (needPhone)
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone (10 digits)', errorText: phoneErr),
            ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final digits = phone.text.replaceAll(RegExp(r'\D'), '');
              setD(() {
                nameErr = name.text.trim().isEmpty ? 'Enter a name' : null;
                phoneErr = needPhone && digits.length != 10 ? 'Not a real phone number' : null;
              });
              if (nameErr == null && phoneErr == null) {
                Navigator.pop(ctx, needPhone ? '${name.text.trim()} – $digits' : name.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}

class EditStudentScreen extends StatefulWidget {
  const EditStudentScreen({super.key});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _s = db.myChild;
  late final _name = TextEditingController(text: _s.name);
  late final _dob = TextEditingController(text: _s.dob);
  late final _allergies = TextEditingController(text: _s.allergies.join(', '));
  late final List<String> _contacts = [..._s.emergencyContacts];
  late final List<String> _pickup = [..._s.approvedPickup];
  late final Map<String, bool> _forms = {..._s.forms};
  String? _nameErr;

  List<String> get _newAllergies =>
      _allergies.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _save() async {
    setState(() => _nameErr = _name.text.trim().isEmpty ? 'Name is required' : null);
    if (_nameErr != null) return;

    final changes = <String>[];
    var risky = false;
    if (_name.text.trim() != _s.name) changes.add('Name: ${_s.name} → ${_name.text.trim()}');
    if (_dob.text.trim() != _s.dob) changes.add('Date of birth updated');
    if (_newAllergies.join(', ') != _s.allergies.join(', ')) {
      changes.add('Allergies: ${_newAllergies.isEmpty ? "none" : _newAllergies.join(", ")}');
      risky = true;
    }
    if (_contacts.join('|') != _s.emergencyContacts.join('|')) changes.add('Emergency contacts updated');
    if (_pickup.join('|') != _s.approvedPickup.join('|')) {
      changes.add('Approved pickup: ${_pickup.join(", ")}');
      risky = true;
    }
    _forms.forEach((k, v) {
      if (_s.forms[k] != v) changes.add('$k: ${v ? "signed" : "missing"}');
    });

    if (changes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes to save')));
      return;
    }
    if (!requireOnline(context)) return; // draft stays on screen

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review your changes'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final c in changes) Text('• $c'),
          if (risky) ...[
            const SizedBox(height: 12),
            const Text(
              'Risky change: this affects who can pick up your child or medical alerts. Please confirm it is correct.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm and save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    _s.name = _name.text.trim();
    _s.dob = _dob.text.trim();
    _s.allergies = _newAllergies;
    _s.emergencyContacts = [..._contacts];
    _s.approvedPickup = [..._pickup];
    _s.forms = {..._forms};
    db.log('Parent', 'updated ${_s.name}: ${changes.join("; ")}');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    Navigator.pop(context);
  }

  Widget _listSection(String title, List<String> items, bool needPhone) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title),
          for (var i = 0; i < items.length; i++)
            ListTile(
              dense: true,
              title: Text(items[i]),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => items.removeAt(i)),
              ),
            ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            onPressed: () async {
              final v = await _askPerson(context, needPhone: needPhone);
              if (v != null) setState(() => items.add(v));
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit student information'), actions: const [OnlineToggle()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const OfflineBanner(),
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: 'Student name', border: const OutlineInputBorder(), errorText: _nameErr),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _dob,
          decoration: const InputDecoration(labelText: 'Date of birth (YYYY-MM-DD)', border: OutlineInputBorder()),
        ),
        const SectionTitle('Allergies / medical alerts'),
        TextField(
          controller: _allergies,
          decoration: const InputDecoration(hintText: 'Separate with commas', border: OutlineInputBorder()),
        ),
        _listSection('Emergency contacts', _contacts, true),
        _listSection('Approved pickup list', _pickup, false),
        const SectionTitle('Consent forms'),
        for (final k in _forms.keys)
          CheckboxListTile(
            title: Text(k),
            subtitle: Text(_forms[k]! ? 'Signed' : 'Missing'),
            value: _forms[k],
            onChanged: (v) => setState(() => _forms[k] = v ?? false),
          ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back'))),
          const SizedBox(width: 12),
          Expanded(child: FilledButton(onPressed: _save, child: const Text('Save'))),
        ]),
      ]),
    );
  }
}