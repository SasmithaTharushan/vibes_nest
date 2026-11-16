# 🌿 Vibes Nest: Your Mental Wellness Companion

Vibes Nest is a Flutter app that brings everyday mental wellness tools into one calm, friendly place: guided breathing, grounding exercises, meditation, journaling, sleep and mood tracking, and a supportive community.

> **Not a medical service.** Vibes Nest supports day-to-day wellbeing. If you are in crisis, open **Get help now** in the app. In Sri Lanka, call **1926** (National Mental Health Helpline, free, 24/7).

![Vibes Nest screens](https://github.com/user-attachments/assets/99717202-42f1-4d6b-82aa-64b830a20d42)

## Features

| Feature | What it does |
|---|---|
| 🫁 **Breath Control** | Animated 4-7-8, Box and Calm breathing with a live countdown and cycle counter |
| 🧘 **Stay Calm** | Step-by-step 5-4-3-2-1 grounding exercise for anxious moments |
| 🔐 **Accounts** | Sign up, sign in, password reset, email verification, delete account |
| 💬 **Talk to Nest** | AI companion (Gemini via Firebase AI Logic) with streaming replies, saved history and tool suggestions. Crisis messages are caught on-device and never sent to the AI |
| 🆘 **Get help now** | One-tap calls to Sri Lankan crisis lines, plus worldwide helplines |
| 🎧 **Meditation & Music** | Curated guided meditations and mood-based playlists |
| 📝 **Let It Go** | Private journal, synced to your account |
| 😴 **Sleep tracker** | Log nights (handles past-midnight bedtimes), star ratings, averages, tomorrow's tasks |
| 📈 **Mood tracker** | Dated check-ins and a 30-day chart |
| 👥 **Community** | Share posts by topic, send "hugs", join the WhatsApp group |
| 📅 **Appointments** | Pick a counsellor, date and time, online or in person |

## Tech stack

- **Flutter 3.50 / Dart 3.14**, Material 3 (`material_ui`)
- **Firebase Authentication** for email/password accounts, password reset and email verification
- **Cloud Firestore** for per-user mood, sleep, journal and task data, with offline caching
- Firestore **security rules** so each user can only read and write their own data (`firestore.rules`)
- `fl_chart` for mood charts, `youtube_player_flutter` for media
- **Firebase AI Logic** (Gemini) for the companion chat; no API key in the app
- Unit and widget tests with `fake_cloud_firestore`, `firebase_auth_mocks` and a fake AI

### Architecture

```
lib/
  main.dart                  App start + AuthGate (Welcome ↔ Home)
  services/
    auth_service.dart        Firebase Auth wrapper, friendly error messages
    app_services.dart        Gives every screen access to services
    local_migration.dart     One-time move of old on-device data to the cloud
    companion_ai.dart        Gemini companion + offline fallback
    crisis_detector.dart     On-device crisis check and tool suggestions
  data/
    wellness_repository.dart Firestore reads/writes under users/{uid}/...
  models/
    wellness_models.dart     MoodEntry, SleepEntry, JournalEntry, TaskItem
  pages/                     UI screens
```

## Getting started

```bash
git clone https://github.com/SasmithaTharushan/vibes_nest.git
cd vibes_nest
flutter pub get
```

### Connect your own Firebase project (one time)

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com).
2. **Authentication → Get started → Email/Password → Enable.**
3. **Firestore Database → Create database** (production mode).
4. Install the tools and connect the app:

   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --project=YOUR_PROJECT_ID --platforms=android
   firebase deploy --only firestore:rules --project YOUR_PROJECT_ID
   ```

Then run the app:

```bash
flutter run
```

Run the tests (no Firebase project needed):

```bash
flutter test
```

## Roadmap

- [x] **Phase 1:** Cleanup, security fixes, no more dead-end screens, crisis support
- [x] **Phase 2:** Firebase Authentication and cloud sync (Firestore)
- [x] **Phase 3:** AI companion powered by Gemini (via Firebase AI Logic, so no keys in the app)
- [ ] **Phase 4:** Real-time community, real appointment booking, "grow a tree" rewards
- [ ] **Phase 5:** Polished UI, CI build, signed release APK

## Author

**Sasmitha Tharushan**. Built as a portfolio project to combine software engineering with wellbeing-focused product design.
