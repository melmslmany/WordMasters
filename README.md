# word_search_game

Word Masters — Flutter word puzzle game (`com.emexp.PureApp`).

## Firebase setup (required after clone)

Secrets are not committed. On a new machine:

```bash
cp lib/firebase_options.example.dart lib/firebase_options.dart
cp android/app/google-services.json.example android/app/google-services.json
# Fill keys from Firebase Console, or run:
flutterfire configure --project=games-dc530
```

Restrict API keys in [Google Cloud Console](https://console.cloud.google.com/apis/credentials) by Android package name and HTTP referrer.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
