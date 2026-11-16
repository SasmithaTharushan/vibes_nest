import 'package:material_ui/material_ui.dart';

import '../models/wellness_models.dart';
import '../services/app_services.dart';
import 'breath_control_page.dart';
import 'crisis_help_page.dart';

/// The 5-4-3-2-1 grounding exercise, for moments of anxiety or panic.
class StayCalmPage extends StatefulWidget {
  const StayCalmPage({super.key});

  @override
  State<StayCalmPage> createState() => _StayCalmPageState();
}

class _Step {
  final int count;
  final String sense;
  final IconData icon;
  final String hint;
  const _Step(this.count, this.sense, this.icon, this.hint);
}

const _steps = [
  _Step(5, 'things you can SEE', Icons.visibility,
      'Look around. A lamp, a tree, your hands, a colour on the wall...'),
  _Step(4, 'things you can TOUCH', Icons.back_hand,
      'Your clothes, the chair under you, the floor beneath your feet...'),
  _Step(3, 'things you can HEAR', Icons.hearing,
      'A fan, traffic outside, your own breathing...'),
  _Step(2, 'things you can SMELL', Icons.air,
      'Soap, coffee, fresh air. If nothing, think of a smell you love.'),
  _Step(1, 'thing you can TASTE', Icons.restaurant,
      'Toothpaste, tea, or just notice the taste in your mouth.'),
];

class _StayCalmPageState extends State<StayCalmPage> {
  int _index = 0;
  bool _done = false;

  void _next() {
    setState(() {
      if (_index < _steps.length - 1) {
        _index++;
      } else {
        _done = true;
      }
    });
    if (_done) {
      final repo = AppServices.maybeRepo(context);
      final messenger = ScaffoldMessenger.of(context);
      repo?.award(Activity.grounding).then((_) => messenger.showSnackBar(
          const SnackBar(content: Text('+3 garden points for grounding 🌱'))),
          onError: (Object _) {});
    }
  }

  void _restart() => setState(() {
        _index = 0;
        _done = false;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text('Stay Calm'),
        backgroundColor: Colors.purple.shade50,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _done ? _buildDone(context) : _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    final step = _steps[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '5-4-3-2-1 Grounding',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Bring yourself back to the present moment, one sense at a time.',
            style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: (_index + 1) / _steps.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const Spacer(),
        Icon(step.icon, size: 80, color: Colors.purple.shade300),
        const SizedBox(height: 24),
        Text(
          'Name ${step.count} ${step.sense}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(step.hint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.4)),
        const Spacer(),
        FilledButton(
          onPressed: _next,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(_index < _steps.length - 1 ? 'Next' : 'Finish'),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(Icons.favorite, size: 80, color: Colors.purple.shade300),
        const SizedBox(height: 24),
        const Text('Well done.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Take a moment to notice how you feel now. '
          'You can repeat this any time you need it.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const BreathControlPage())),
          icon: const Icon(Icons.air),
          label: const Text('Try a breathing exercise'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.replay),
          label: const Text('Do it again'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CrisisHelpPage())),
          icon: const Icon(Icons.phone, color: Colors.red),
          label: const Text('Still feeling overwhelmed? Get help now',
              style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
