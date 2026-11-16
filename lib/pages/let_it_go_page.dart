import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../models/wellness_models.dart';
import '../services/app_services.dart';

class LetItGoPage extends StatefulWidget {
  const LetItGoPage({super.key});

  @override
  State<LetItGoPage> createState() => _LetItGoPageState();
}

class _LetItGoPageState extends State<LetItGoPage> {
  final TextEditingController _journalController = TextEditingController();

  static final List<Color> _noteColors = [
    Colors.yellow[200]!,
    Colors.pink[200]!,
    Colors.green[200]!,
    Colors.blue[200]!,
    Colors.orange[200]!,
    Colors.purple[200]!,
  ];

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  // Stable colour per note, so notes don't change colour on every rebuild.
  Color _colorFor(JournalEntry e) =>
      _noteColors[e.id.hashCode.abs() % _noteColors.length];

  Future<void> _saveEntry() async {
    final text = _journalController.text.trim();
    if (text.isEmpty) return;
    _journalController.clear();
    FocusScope.of(context).unfocus();
    await AppServices.repo(context).addJournal(text);
  }

  Future<void> _clearEntries() async {
    final repo = AppServices.repo(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Let go of all notes?'),
        content: const Text('This deletes every note. It cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete all')),
        ],
      ),
    );
    if (ok == true) await repo.clearJournal();
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppServices.repo(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Let It Go'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<JournalEntry>>(
          stream: repo.watchJournal(),
          builder: (context, snapshot) {
            final entries = snapshot.data ?? const <JournalEntry>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Write down your thoughts and let go of your worries ✨💭',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _journalController,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Write here...',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: 'save-note',
                      onPressed: _saveEntry,
                      backgroundColor: Colors.blueGrey,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Your Sticky Notes:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (entries.isNotEmpty)
                      TextButton.icon(
                        onPressed: _clearEntries,
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text('Clear All',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: !snapshot.hasData && !snapshot.hasError
                      ? const Center(child: CircularProgressIndicator())
                      : entries.isEmpty
                          ? const Center(
                              child: Text(
                                'No thoughts saved. Write something! 😊',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: entries.length,
                              itemBuilder: (context, index) =>
                                  _buildStickyNote(entries[index]),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStickyNote(JournalEntry entry) {
    final repo = AppServices.repo(context);
    return Dismissible(
      key: ValueKey(entry.id),
      onDismissed: (_) => repo.deleteJournal(entry.id),
      background: Container(
        color: const Color.fromARGB(255, 75, 75, 75),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _colorFor(entry),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(entry.text,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
            Row(
              children: [
                Text(DateFormat('d MMM').format(entry.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const Spacer(),
                IconButton(
                  tooltip: 'Delete note',
                  icon: const Icon(Icons.delete,
                      color: Color.fromARGB(255, 155, 33, 24)),
                  onPressed: () => repo.deleteJournal(entry.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
