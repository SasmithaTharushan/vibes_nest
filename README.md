# 🌿 Vibes Nest: Your Mental Wellness Companion

Vibes Nest is a Flutter app that brings everyday mental wellness tools into one calm, friendly place: guided breathing, grounding exercises, meditation, journaling, sleep and mood tracking, and a supportive community.

> **Not a medical service.** Vibes Nest supports day-to-day wellbeing. If you are in crisis, open **Get help now** in the app. In Sri Lanka, call **1926** (National Mental Health Helpline, free, 24/7).

![Vibes Nest screens](https://github.com/user-attachments/assets/99717202-42f1-4d6b-82aa-64b830a20d42)

## Features

| Feature | What it does |
|---|---|
| 🫁 **Breath Control** | Animated 4-7-8, Box and Calm breathing with a live countdown and cycle counter |
| 🧘 **Stay Calm** | Step-by-step 5-4-3-2-1 grounding exercise for anxious moments |
| 💬 **Talk to Nest** | Supportive companion chat that suggests the right tool and detects crisis language |
| 🆘 **Get help now** | One-tap calls to Sri Lankan crisis lines, plus worldwide helplines |
| 🎧 **Meditation & Music** | Curated guided meditations and mood-based playlists |
| 📝 **Let It Go** | Private journal to write down and release worries |
| 😴 **Sleep tracker** | Log bed and wake times and get sleep-quality tips |
| 📈 **Mood tracker** | Chart how you feel over time |
| 👥 **Community** | Share posts by topic, send "hugs", join the WhatsApp group |
| 📅 **Appointments** | Pick a counsellor, date and time, online or in person |

## Tech stack

- **Flutter 3.50 / Dart 3.14**, Material 3 (`material_ui`)
- `shared_preferences` for on-device storage
- `fl_chart` for mood charts, `youtube_player_flutter` for media
- Widget tests with `flutter_test`

## Getting started

```bash
git clone https://github.com/SasmithaTharushan/vibes_nest.git
cd vibes_nest
flutter pub get
flutter run
```

Run the tests:

```bash
flutter test
```

## Roadmap

- [x] **Phase 1:** Cleanup, security fixes, no more dead-end screens, crisis support
- [ ] **Phase 2:** Firebase Authentication and cloud sync (Firestore)
- [ ] **Phase 3:** AI companion powered by Gemini (via Firebase AI Logic, so no keys in the app)
- [ ] **Phase 4:** Real-time community, real appointment booking, "grow a tree" rewards
- [ ] **Phase 5:** Polished UI, CI build, signed release APK

## Author

**Sasmitha Tharushan**. Built as a portfolio project to combine software engineering with wellbeing-focused product design.
