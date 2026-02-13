# slinky

slinky is a Flutter campus communication app prototype with role-based access,
agenda/resource workflows, peer matching, and post feedback.

## Features

- Role-based experience (`student`, `staff`, `hod`, `admin`) with clearance filtering.
- Student-only **Resources** tab in the right sidebar.
- Agenda management (add/remove posts to personal agenda).
- Peer Match cards with **Request Session** action and request status.
- Post feedback section with shared Firestore mode and local fallback mode.
- Profile setup flow after login, then editable anytime.
- Dark/light theme toggle.
- Functional quick actions:
  - Create channel
  - Create post
  - Post actions menu (`...`) for agenda/copy/refresh feedback

## Role behavior

- **Student**
  - Sees channels based on clearance and staff-controlled student visibility.
  - Sees Resources + Peer Match.
  - Sets profile using `pillar` (`CSD`, `DAI`, `EPD`, `ESD`, `ASD`) + year.
- **Staff**
  - Sets department in profile.
  - Can control whether student-visible channels are shown to students.
  - Does not see student-only Resources section.
- **HOD/Admin**
  - Auto-detected from institutional email patterns.
  - Higher clearance visibility.

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Run:

```bash
flutter run
```

## Firebase behavior (hybrid fallback)

- App attempts `Firebase.initializeApp()` at startup.
- If Firebase is configured and available:
  - Feedback and session requests use Firestore.
- If Firebase is unavailable:
  - App falls back to local in-memory behavior for those features.

## Main user flow

1. Login with email + OTP.
2. If profile incomplete, user is routed to:
  - core profile setup page
  - preferences page (topics, work ethics, values)
3. Main screen opens (left channels, center posts/detail, right quick actions).

## Project structure

- `lib/main.dart` - app bootstrap and theme mode handling.
- `lib/providers/providers.dart` - app state (auth, channels, agenda, feedback, requests).
- `lib/screens/` - login, main screen, profile setup/preferences.
- `lib/widgets/` - channel list, post list/detail, quick actions sidebar.
- `lib/models/models.dart` - user/channel/post models.

## Developer notes

- Update seeded study resources in:
  - `lib/widgets/quick_actions.dart` (`_studentResources`)
- Update pillar/department options in:
  - `lib/screens/profile_setup_screen.dart`
- Update profile preference option sets in:
  - `lib/screens/profile_preferences_screen.dart`
- Update peer match scoring and session request handling in:
  - `lib/providers/providers.dart`
- Update feedback data flow (Firestore/local fallback) in:
  - `lib/providers/providers.dart`
