# tum — Save & Think

A small Flutter app to help users avoid impulsive purchases. Add items you want to buy and set a waiting period; the app will remind you later to confirm whether you really bought it. Built with Riverpod and local storage (Hive recommended).

Quick start

1. Open the project in your terminal:

   cd ~/Desktop/CODE/01_flutter/tum

2. Install dependencies:

   flutter pub get

3. Run the app:

   flutter run

Architecture

- State management: Riverpod (flutter_riverpod)
- Suggested storage: Hive for local persistence
- Notifications: flutter_local_notifications for local reminders

Next steps

- Implement Hive adapters and persistence
- Wire NotificationService.init() during app startup
- Build Item list / add / detail screens
- Integrate AdMob (google_mobile_ads) for monetization (test ids first)

Branch

Working branch: feat/riverpod-setup
