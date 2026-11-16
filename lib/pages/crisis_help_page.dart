import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Emergency and crisis support contacts (Sri Lanka first, then worldwide).
class CrisisHelpPage extends StatelessWidget {
  const CrisisHelpPage({super.key});

  static const _lines = [
    _Helpline(
      name: 'National Mental Health Helpline',
      detail: 'National Institute of Mental Health · free, 24/7',
      number: '1926',
    ),
    _Helpline(
      name: 'CCCline',
      detail: 'Free emotional support and crisis line, 24/7',
      number: '1333',
    ),
    _Helpline(
      name: 'Sumithrayo',
      detail: 'Confidential emotional support',
      number: '0112696666',
      display: '011 269 6666',
    ),
    _Helpline(
      name: 'Suwa Seriya Ambulance',
      detail: 'Medical emergency',
      number: '1990',
    ),
    _Helpline(
      name: 'Police Emergency',
      detail: 'If you or someone else is in immediate danger',
      number: '119',
    ),
  ];

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the dialer. Please call $number.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get help now'),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'If you are thinking about harming yourself or feel unsafe, '
              'please reach out right now. You don\'t have to go through '
              'this alone. Talking to someone can help.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          for (final line in _lines)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.phone, color: Colors.white),
                ),
                title: Text(line.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${line.display ?? line.number} · ${line.detail}'),
                trailing: FilledButton(
                  onPressed: () => _call(context, line.number),
                  child: const Text('Call'),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Outside Sri Lanka?'),
              subtitle: const Text('Find a free, confidential helpline in your country'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(Uri.parse('https://findahelpline.com'),
                  mode: LaunchMode.externalApplication),
            ),
          ),
        ],
      ),
    );
  }
}

class _Helpline {
  final String name;
  final String detail;
  final String number;
  final String? display;
  const _Helpline({
    required this.name,
    required this.detail,
    required this.number,
    this.display,
  });
}
