import 'package:material_ui/material_ui.dart';

import '../data/help_directory.dart';
import '../widgets/help_service_card.dart';
import 'crisis_help_page.dart';

/// A directory of real Sri Lankan mental health and support services.
class FindHelpPage extends StatefulWidget {
  const FindHelpPage({super.key});

  @override
  State<FindHelpPage> createState() => _FindHelpPageState();
}

class _FindHelpPageState extends State<FindHelpPage> {
  HelpCategory? _category;
  String _query = '';

  List<HelpService> get _visible => helpServices.where((s) {
        if (_category != null && s.category != _category) return false;
        if (_query.isEmpty) return true;
        final q = _query.toLowerCase();
        return s.name.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q);
      }).toList();

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(title: const Text('Find professional help')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.sos, color: Colors.red),
              title: const Text('In crisis right now?'),
              subtitle: const Text('Call 1926 or 1333, free and 24/7'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CrisisHelpPage())),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Talking to a trained counsellor can really help. These services are '
            'free or low-cost, confidential, and you can contact them directly.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search services',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v.trim()),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in HelpCategory.values)
                ChoiceChip(
                  label: Text(c.title),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text('No services match your search.',
                  textAlign: TextAlign.center),
            ),
          for (final category in HelpCategory.values)
            if (visible.any((s) => s.category == category)) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(category.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              for (final s in visible.where((s) => s.category == category))
                HelpServiceCard(service: s),
            ],
          const SizedBox(height: 8),
          Text(
            'Details verified on $lastVerified from each organisation\'s '
            'official website. Services can change, so please confirm hours '
            'when you call.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
