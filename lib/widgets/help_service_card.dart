import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/help_directory.dart';

/// A contact card with Call / WhatsApp / Website buttons.
class HelpServiceCard extends StatelessWidget {
  const HelpServiceCard({super.key, required this.service, this.urgent = false});

  final HelpService service;

  /// Red styling for crisis screens.
  final bool urgent;

  Future<void> _open(BuildContext context, Uri uri, String fallback) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(fallback)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = service;
    final details = [
      if (s.phoneLabel != null) s.phoneLabel!,
      if (s.hours != null) s.hours!,
      if (s.languages != null) s.languages!,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(s.description, style: const TextStyle(height: 1.3)),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(details,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                if (s.phone != null)
                  FilledButton.icon(
                    style: urgent
                        ? FilledButton.styleFrom(backgroundColor: Colors.red.shade600)
                        : null,
                    onPressed: () => _open(
                        context,
                        Uri(scheme: 'tel', path: s.phone),
                        'Could not open the dialer. Please call ${s.phoneLabel}.'),
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text('Call ${s.phoneLabel}'),
                  ),
                if (s.whatsapp != null)
                  OutlinedButton.icon(
                    onPressed: () => _open(
                        context,
                        Uri.parse('https://wa.me/${s.whatsapp}'),
                        'Could not open WhatsApp.'),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('WhatsApp'),
                  ),
                if (s.website != null)
                  TextButton.icon(
                    onPressed: () => _open(context, Uri.parse(s.website!),
                        'Could not open the website.'),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Website'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
