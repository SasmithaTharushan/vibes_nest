import 'package:firebase_ai/firebase_ai.dart';

import 'crisis_detector.dart';

/// One message in a conversation.
class ChatTurn {
  const ChatTurn({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}

/// Something that can reply to the user. The real app uses Gemini; tests use
/// a fake; [OfflineCompanion] is the fallback when the AI is unreachable.
abstract class CompanionAi {
  /// Streams the reply in pieces as it is generated.
  Stream<String> reply({required List<ChatTurn> history, required String message});
}

/// Gemini through Firebase AI Logic. No API key ships in the app: requests go
/// through Firebase, which is tied to this app's registered Firebase project.
class GeminiCompanionAi implements CompanionAi {
  GeminiCompanionAi({this.modelName = defaultModel});

  static const defaultModel = 'gemini-3.5-flash-lite';

  /// How many earlier messages to send for context (keeps cost and latency low).
  static const historyLimit = 20;

  final String modelName;
  GenerativeModel? _model;

  static const systemPrompt = '''
You are Nest, the supportive companion inside Vibes Nest, a mental wellbeing app.

How you talk:
- Warm, calm, kind and non-judgmental. Validate feelings before offering ideas.
- Short replies: 2 to 5 sentences, plain everyday language. No lists unless asked.
- Ask at most one gentle follow-up question at a time.
- Reply in the same language the person writes in (for example English or Sinhala).

What you can suggest (only when it fits naturally):
- Breath Control: guided 4-7-8 or box breathing for stress.
- Stay Calm: the 5-4-3-2-1 grounding exercise for anxiety or panic.
- Let It Go: a private journal for heavy thoughts.
- The sleep tracker, meditation and calming music.
- Talking to someone they trust, or a professional counsellor.

Boundaries (always follow these):
- You are not a therapist or doctor. Never diagnose, never name medications or
  doses, and never give medical, legal or financial advice.
- If someone mentions suicide, self-harm, wanting to die, abuse, or being in
  danger, respond with care and clearly encourage them to contact the 1926
  National Mental Health Helpline in Sri Lanka (free, 24/7) or emergency
  services on 119 right now. Do not try to handle a crisis alone.
- Never encourage harmful behaviour, and never shame or lecture.
- If asked, say honestly that you are an AI.
- Stay on wellbeing topics; gently steer back if asked about unrelated things.
''';

  GenerativeModel get _gemini => _model ??= FirebaseAI.googleAI().generativeModel(
        model: modelName,
        systemInstruction: Content.system(systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 500,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium, null),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium, null),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium, null),
        ],
      );

  @override
  Stream<String> reply({
    required List<ChatTurn> history,
    required String message,
  }) async* {
    final recent = history.length > historyLimit
        ? history.sublist(history.length - historyLimit)
        : history;
    final chat = _gemini.startChat(history: [
      for (final t in recent)
        t.fromUser ? Content.text(t.text) : Content.model([TextPart(t.text)]),
    ]);
    await for (final chunk in chat.sendMessageStream(Content.text(message))) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) yield text;
    }
  }
}

/// Rule-based replies used when there is no internet or the AI fails.
class OfflineCompanion implements CompanionAi {
  const OfflineCompanion();

  static String replyFor(String message) {
    switch (CrisisDetector.suggestTool(message)) {
      case CompanionTool.crisis:
        return CrisisDetector.crisisReply;
      case CompanionTool.grounding:
        return "That sounds really hard. When anxiety rises, grounding yourself "
            "in the present can help. Want to try the 5-4-3-2-1 exercise together?";
      case CompanionTool.breathing:
        return "Stress builds up in the body. A few minutes of slow breathing "
            "can calm your nervous system. Shall we breathe together?";
      case CompanionTool.sleep:
        return "Rest matters so much. Tracking your sleep can help you spot "
            "patterns, and 4-7-8 breathing before bed helps many people.";
      case CompanionTool.journal:
        return "I hear you, and your feelings are valid. Sometimes writing "
            "things down helps lift the weight a little.";
      case null:
        final text = message.toLowerCase();
        if (text.contains('thank')) {
          return "You're welcome. I'm here whenever you need to talk.";
        }
        if (RegExp(r'\b(happy|good|great|better|fine|okay)\b').hasMatch(text)) {
          return "I'm so glad to hear that! What's one thing that made today a little better?";
        }
        return "Thank you for sharing that with me. Tell me more. What's on "
            "your mind, and how is it making you feel?";
    }
  }

  @override
  Stream<String> reply({
    required List<ChatTurn> history,
    required String message,
  }) =>
      Stream.value(replyFor(message));
}
