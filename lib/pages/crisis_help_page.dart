import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/help_directory.dart';
import '../widgets/help_service_card.dart';

/// Emergency and crisis support contacts (Sri Lanka first, then worldwide).
class CrisisHelpPage extends StatelessWidget {
  const CrisisHelpPage({super.key});

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
          for (final s in crisisLines) HelpServiceCard(service: s, urgent: true),
          Card(
            child: ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Outside Sri Lanka?'),
              subtitle:
                  const Text('Find a free, confidential helpline in your country'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(Uri.parse('https://findahelpline.com'),
                  mode: LaunchMode.externalApplication),
            ),
          ),
          const SizedBox(height: 8),
          Text('Numbers verified on $lastVerified.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
