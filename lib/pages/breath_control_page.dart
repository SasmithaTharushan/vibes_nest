import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// A guided breathing exercise with an animated circle.
class BreathControlPage extends StatefulWidget {
  const BreathControlPage({super.key});

  @override
  State<BreathControlPage> createState() => _BreathControlPageState();
}

class _Phase {
  final String label;
  final int seconds;
  final double targetScale; // 0.5 = small, 1.0 = full
  const _Phase(this.label, this.seconds, this.targetScale);
}

class _Pattern {
  final String name;
  final String description;
  final List<_Phase> phases;
  const _Pattern(this.name, this.description, this.phases);
}

const _patterns = [
  _Pattern('4-7-8', 'Helps you relax and fall asleep', [
    _Phase('Breathe in', 4, 1.0),
    _Phase('Hold', 7, 1.0),
    _Phase('Breathe out', 8, 0.5),
  ]),
  _Pattern('Box', 'Calms the mind and improves focus', [
    _Phase('Breathe in', 4, 1.0),
    _Phase('Hold', 4, 1.0),
    _Phase('Breathe out', 4, 0.5),
    _Phase('Hold', 4, 0.5),
  ]),
  _Pattern('Calm', 'Simple slow breathing (5 in, 5 out)', [
    _Phase('Breathe in', 5, 1.0),
    _Phase('Breathe out', 5, 0.5),
  ]),
];

class _BreathControlPageState extends State<BreathControlPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;
  _Pattern _pattern = _patterns.first;
  int _phaseIndex = 0;
  int _secondsLeft = 0;
  int _cycles = 0;
  bool _running = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scale = const AlwaysStoppedAnimation(0.5);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _cycles = 0;
      _phaseIndex = 0;
    });
    _runPhase(from: 0.5);
  }

  void _stop() {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      _running = false;
      _scale = const AlwaysStoppedAnimation(0.5);
    });
  }

  void _runPhase({required double from}) {
    final phase = _pattern.phases[_phaseIndex];
    _controller.duration = Duration(seconds: phase.seconds);
    _scale = Tween<double>(begin: from, end: phase.targetScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward(from: 0);
    setState(() => _secondsLeft = phase.seconds);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
        return;
      }
      t.cancel();
      final next = (_phaseIndex + 1) % _pattern.phases.length;
      setState(() {
        if (next == 0) _cycles++;
        _phaseIndex = next;
      });
      _runPhase(from: phase.targetScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = _pattern.phases[_phaseIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Breath Control')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final p in _patterns)
                    ChoiceChip(
                      label: Text(p.name),
                      selected: p == _pattern,
                      onSelected: _running
                          ? null
                          : (_) => setState(() => _pattern = p),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_pattern.description,
                  style: TextStyle(color: Colors.grey.shade700)),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final size = 260 * _scale.value;
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            Colors.lightBlue.shade200,
                            Colors.blue.shade600,
                          ]),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _running
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(phase.label,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600)),
                                  Text('$_secondsLeft',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 36)),
                                ],
                              )
                            : const Icon(Icons.air,
                                color: Colors.white, size: 48),
                      );
                    },
                  ),
                ),
              ),
              Text('Cycles completed: $_cycles',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _running ? _stop : _start,
                  icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                  label: Text(_running ? 'Stop' : 'Start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
