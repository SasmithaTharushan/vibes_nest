import 'package:material_ui/material_ui.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const _faqs = [
    (
      'What is Vibes Nest?',
      'Vibes Nest is a wellness companion. It brings together breathing '
          'exercises, meditation, a journal, sleep and mood tracking, and a '
          'supportive community in one place.'
    ),
    (
      'Is Vibes Nest a replacement for therapy?',
      'No. Vibes Nest supports your wellbeing day to day, but it is not '
          'medical care. If you are struggling, please talk to a doctor or '
          'counsellor. If you are in crisis, open "Get help now" for helplines.'
    ),
    (
      'Where is my data stored?',
      'Your moods, sleep logs, journal, tasks and chats are stored securely in '
          'your account with Google Firebase, so they sync across devices. Only '
          'you can read them. You can delete everything from Profile → Delete '
          'account. See the Privacy policy in your Profile for details.'
    ),
    (
      'Is "Talk to Nest" a real person?',
      'No. Nest is an AI companion powered by Google Gemini. It can listen and '
          'suggest helpful tools, but it is not a therapist. If you are in '
          'crisis, Nest shows helplines instead, and those messages are never '
          'sent to the AI.'
    ),
    (
      'Can other people see who I am in the Community?',
      'No. You appear under a friendly nickname like "Calm Otter". Your name '
          'and email are never shown. You can delete your own posts at any '
          'time, and report posts that are unkind or unsafe.'
    ),
    (
      'How does My Garden work?',
      'Each bit of self-care earns points: a mood check-in, a journal note, a '
          'sleep log, or finishing a breathing or grounding session. Every 10 '
          'points grows a new plant. Do something each day to build a streak.'
    ),
    (
      'How do I use the breathing exercises?',
      'Open Breathe → Breath Control, choose a pattern such as 4-7-8 or Box '
          'breathing, and press Start. Follow the circle as it grows and shrinks.'
    ),
    (
      'What is the 5-4-3-2-1 exercise?',
      'It is a grounding technique for anxious moments. You name things you '
          'can see, touch, hear, smell and taste to bring your attention back '
          'to the present. Find it under Calm → Stay Calm.'
    ),
    (
      'How do I contact the developer?',
      'Open an issue on the Vibes Nest GitHub repository. Feedback is welcome!'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final (question, answer) in _faqs)
            Card(
              child: ExpansionTile(
                title: Text(question,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [Text(answer, style: const TextStyle(height: 1.4))],
              ),
            ),
        ],
      ),
    );
  }
}
