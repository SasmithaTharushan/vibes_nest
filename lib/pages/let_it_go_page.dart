import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LetItGoPage extends StatefulWidget {
  const LetItGoPage({super.key});

  @override
  _LetItGoPageState createState() => _LetItGoPageState();
}

class _LetItGoPageState extends State<LetItGoPage> {
  final TextEditingController _journalController = TextEditingController();
  List<String> _entries = [];
  final List<Color> _noteColors = [
    Colors.yellow[200]!,
    Colors.pink[200]!,
    Colors.green[200]!,
    Colors.blue[200]!,
    Colors.orange[200]!,
    Colors.purple[200]!,
  ];

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _entries = prefs.getStringList('journal_entries') ?? [];
    });
  }

  Future<void> _saveEntry() async {
    if (_journalController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _entries.insert(0, _journalController.text);
      await prefs.setStringList('journal_entries', _entries);
      _journalController.clear();
      setState(() {});
    }
  }

  Future<void> _clearEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('journal_entries');
    setState(() {
      _entries.clear();
    });
  }

  Future<void> _deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _entries.removeAt(index);
    });
    await prefs.setStringList('journal_entries', _entries);
  }

  Color _getRandomNoteColor() {
    final random = Random();
    return _noteColors[random.nextInt(_noteColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Let It Go'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading with emoji
            const Text(
              "Write down your thoughts and let go of your worries ✨💭",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Notebook-like Input Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _journalController,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Write here...",
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
                  onPressed: _saveEntry,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (_entries.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearEntries,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text(
                    "Clear All",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            const Text(
              "Your Sticky Notes:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Sticky Notes Grid
            Expanded(
              child: _entries.isEmpty
                  ? const Center(
                      child: Text(
                        "No thoughts saved. Write something! 😊",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two sticky notes per row
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        return _buildStickyNote(_entries[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyNote(String text, int index) {
    return Dismissible(
      key: Key(text),
      onDismissed: (direction) {
        _deleteEntry(index);
      },
      background: Container(
        color: const Color.fromARGB(255, 75, 75, 75),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _getRandomNoteColor(),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.delete,
                    color: Color.fromARGB(255, 155, 33, 24)),
                onPressed: () => _deleteEntry(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
