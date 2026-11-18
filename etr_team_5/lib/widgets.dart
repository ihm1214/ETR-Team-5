import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'models.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

/// Returns false (and shows a message) if the app is "offline".
bool requireOnline(BuildContext context) {
  if (db.online.value) return true;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Cannot submit at this time. Please connect to the internet to continue. Your draft is saved.'),
  ));
  return false;
}

/// Wi-Fi icon in the app bar to simulate losing the connection.
class OnlineToggle extends StatelessWidget {
  const OnlineToggle({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: db.online,
        builder: (context, on, _) => IconButton(
          tooltip: on ? 'Online (tap to simulate offline)' : 'Offline (tap to reconnect)',
          icon: Icon(on ? Icons.wifi : Icons.wifi_off),
          onPressed: () => db.online.value = !on,
        ),
      );
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: db.online,
        builder: (context, on, _) => on
            ? const SizedBox.shrink()
            : Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Text('You are offline. Showing saved data; changes wait until you reconnect.'),
              ),
      );
}

class AlertBadge extends StatelessWidget {
  const AlertBadge(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: const Icon(Icons.warning_amber, size: 18, color: Colors.red),
        label: Text(label),
        visualDensity: VisualDensity.compact,
        backgroundColor: Colors.red.shade50,
      );
}

/// "Information needed" banner with a form progress indicator.
class FormProgressBanner extends StatelessWidget {
  const FormProgressBanner({super.key, required this.student});
  final Student student;

  @override
  Widget build(BuildContext context) {
    final total = student.forms.length;
    final missing = student.missingForms;
    if (missing.isEmpty) return const SizedBox.shrink();
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Information needed', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (total - missing.length) / total),
          const SizedBox(height: 8),
          Text('${total - missing.length} of $total forms complete. Missing: ${missing.join(', ')}'),
        ]),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  const StudentCard({super.key, required this.student, this.subtitle, this.trailing, this.onTap});
  final Student student;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(child: Text(student.name[0])),
          title: Text(student.name),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (subtitle != null) Text(subtitle!),
            if (student.allergies.isNotEmpty)
              Wrap(spacing: 6, children: [for (final a in student.allergies) AlertBadge(a)]),
          ]),
          trailing: trailing,
          onTap: onTap,
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      );
}

Future<void> showMessageDialog(BuildContext context, String from) async {
  final c = TextEditingController();
  final send = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New message'),
      content: TextField(controller: c, maxLines: 3, decoration: const InputDecoration(hintText: 'Type your message')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send')),
      ],
    ),
  );
  if (send == true && c.text.trim().isNotEmpty) {
    if (!context.mounted) return;
    if (!requireOnline(context)) return;
    db.messages.insert(0, Message(from: from, text: c.text.trim(), sent: kToday));
    db.log(from, 'sent a message');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent')));
  }
}

/// Staff see alerts + necessities only. Director also sees DOB and can add a note.
void showStudentDetails(BuildContext context, Student s, {required UserRole viewer, VoidCallback? onPickup}) {
  Widget h(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.name, style: Theme.of(ctx).textTheme.headlineSmall),
          if (viewer == UserRole.director) Text('Date of birth: ${s.dob}'),
          h('Alerts'),
          if (s.allergies.isEmpty)
            const Text('No allergy alerts')
          else
            Wrap(spacing: 8, children: [for (final a in s.allergies) AlertBadge('Allergy: $a')]),
          h('Emergency contacts'),
          for (final c in s.emergencyContacts) Text('• $c'),
          h('Approved pickup'),
          for (final p in s.approvedPickup) Text('• $p'),
          h('Missing forms'),
          Text(s.missingForms.isEmpty ? 'None' : s.missingForms.join(', ')),
          if (viewer == UserRole.director) ...[
            h('Director note'),
            TextFormField(
              initialValue: s.directorNote,
              maxLines: 2,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Add a note'),
              onChanged: (v) {
                s.directorNote = v;
                db.log('Director', 'edited note for ${s.name}');
              },
            ),
          ],
          if (onPickup != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Pickup / sign out'),
                onPressed: () {
                  Navigator.pop(ctx);
                  onPickup();
                },
              ),
            ),
          ],
        ]),
      ),
    ),
  );
}