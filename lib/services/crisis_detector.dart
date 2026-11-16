/// In-app tools the companion can point someone to.
enum CompanionTool {
  crisis('Get help now'),
  grounding('Start grounding'),
  breathing('Breathe with me'),
  sleep('Open sleep tracker'),
  journal('Write it down');

  const CompanionTool(this.label);
  final String label;

  static CompanionTool? fromName(String? name) {
    for (final t in values) {
      if (t.name == name) return t;
    }
    return null;
  }
}

/// Keyword checks that run on the device, before anything is sent to the AI.
///
/// Crisis detection deliberately runs first and does not depend on the AI or
/// the network: if someone may be at risk, they get helplines immediately.
class CrisisDetector {
  static const _crisisPhrases = [
    'suicide', 'suicidal', 'kill myself', 'killing myself', 'end my life',
    'end it all', 'self harm', 'self-harm', 'selfharm', 'hurt myself',
    'harm myself', 'cut myself', 'cutting myself', 'want to die',
    'wanna die', "don't want to live", 'dont want to live',
    'no reason to live', 'better off dead', 'better off without me',
    'take my own life', 'overdose',
  ];

  static const _toolKeywords = <CompanionTool, List<String>>{
    CompanionTool.grounding: [
      'anxious', 'anxiety', 'panic', 'scared', 'nervous', 'overwhelm',
    ],
    CompanionTool.breathing: [
      'stress', 'stressed', 'tense', 'angry', 'frustrat', 'calm down',
    ],
    CompanionTool.sleep: [
      'sleep', 'insomnia', 'tired', 'exhausted', "can't rest", 'awake all night',
    ],
    CompanionTool.journal: [
      'sad', 'down', 'lonely', 'alone', 'cry', 'depress', 'hopeless',
      'worried', 'worry', 'heartbroken',
    ],
  };

  static String _normalise(String text) =>
      text.toLowerCase().replaceAll('’', "'").replaceAll(RegExp(r'\s+'), ' ');

  /// True when the message suggests the person may be at risk of harm.
  static bool isCrisis(String message) {
    final text = _normalise(message);
    return _crisisPhrases.any(text.contains);
  }

  /// The most relevant in-app tool for this message, if any.
  static CompanionTool? suggestTool(String message) {
    if (isCrisis(message)) return CompanionTool.crisis;
    final text = _normalise(message);
    for (final entry in _toolKeywords.entries) {
      if (entry.value.any(text.contains)) return entry.key;
    }
    return null;
  }

  /// The fixed, caring reply shown for crisis messages. Never AI-generated.
  static const crisisReply =
      "I'm really sorry you're feeling this way, and I'm glad you told me. "
      "You deserve support right now from a real person. Please call the "
      "1926 National Mental Health Helpline (free, 24/7), or tap below for "
      "more options. If you are in immediate danger, call 119.";
}
