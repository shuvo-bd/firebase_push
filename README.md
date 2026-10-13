# daymark | Firebase task manager

A Flutter task manager assignment with email/password and Google authentication, user-scoped Cloud Firestore tasks, FCM push handling, and local notifications for foreground messages.

## Run the preview

```sh
flutter pub get
flutter run
```

If Firebase isn't configured, the sign-in screen offers an offline preview. Preview tasks live in memory for the current app session; they are not synced or persisted.

## Connect Firebase

1. Create a Firebase project and register the Android and iOS apps using the identifiers in the native project files.
2. In Firebase Authentication, enable Email/Password and Google providers.
3. Download `google-services.json` into `android/app/` and `GoogleService-Info.plist` into `ios/Runner/`.
4. For web, run `flutterfire configure`, then initialize Firebase in `lib/main.dart` with the generated `DefaultFirebaseOptions.currentPlatform` from `lib/firebase_options.dart`.
5. For Android Google Sign-In, add your debug and release SHA-1 fingerprints in Firebase project settings. For iOS, configure the reversed client ID URL scheme from `GoogleService-Info.plist` if the generated setup does not add it.
6. Apply the rules in `firestore.rules` from the Firebase console or with the Firebase CLI.
7. Run the app again. The configured app requests notification permission and logs its FCM registration token to the debug console.

Firebase platform configuration is intentionally not committed because it contains project-specific identifiers and this workspace has no Firebase project credentials.

## Push notification checks

Use the registration token printed by the app to send a Firebase Console test message. For a task deep link, include custom data such as:

```json
{
	"taskId": "TASK_DOCUMENT_ID",
	"priority": "2"
}
```

Use a notification title and body, for example `New Task` and `You have a new task: Complete Flutter Assignment`. Foreground messages are converted to local notifications; background/terminated messages are handled by FCM. Tapping a message opens the task list and opens the matching task when `taskId` exists in the signed-in user's collection.

For iOS delivery, configure an APNs authentication key in Firebase and enable Push Notifications and Background Modes in the Runner target. The Firebase Console or a trusted server should send test pushes; never embed server keys in the app.

## Firestore data

Each signed-in user's tasks are stored at `users/{uid}/tasks/{taskId}` with `title`, `description`, `dueDate`, `priority` (`0` low, `1` medium, `2` high), `isCompleted`, and `createdAt` fields.

## Verify

```sh
flutter test
flutter analyze
```
# firebase_push

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
