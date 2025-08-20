# CLAUDE.md

## 📌 Critical Rules  
- Keep this file lean; remove any block that stops being true.  
- Respect the SIMPLE principle: **S**mall **I**ncremental **M**odular **P**redictable **L**ight **E**volvable.  
- All code, tests, docs and commit messages are English; UI text is localized in-app.  
- Any new dependency ➜ add to `pubspec.yaml` under appropriate section.  
- **NO EMOJI ICONS**: Never use emojis as icons in UI components. Always use Material Icons (Icons.*) instead. Emojis are only acceptable in user-generated text content.
- **IMPORTANT**: After completing ANY changes, update `Changelog.md` with topic and what changed.

## 🗂 Project Snapshot (Aug 2025)  
- App name: **ආයු** (Ayu) – child-nutrition tracker for Sri Lankan parents.  
- Stack: Flutter 3.x | Dart 3.x | Material 3 | Provider for state management.  
- Min iOS 12.0, Min Android API 21.  
- Navigation via GoRouter with bottom navigation.  
- Offline-first; SQLite + SharedPreferences cache, Firebase only for sync.  
- Typeface: **Noto Serif Sinhala** via Google Fonts.  

## 🔧 Build & Test Quick-Commands  
```bash
flutter pub get               # install dependencies  
flutter run                   # run debug build  
flutter build apk            # build Android APK  
flutter build ios            # build iOS app  
flutter test                 # unit & widget tests  
flutter test integration_test # integration tests  
flutter analyze              # static analysis  
```

## 🏗 Directory Convention  
```
lib/
 ├─ models/        # Data models & entities
 ├─ services/      # SQLite, API, Firebase services
 ├─ providers/     # State management providers
 ├─ screens/       # Screen widgets
 ├─ widgets/       # Reusable UI components
 ├─ utils/         # Helper functions, constants
 └─ l10n/          # Localization files
```

## 🎨 UI Guidelines  
- Material 3 theme with dynamic color support.  
- Bottom navigation for: Home, Growth, Vaccines, Learn, Profile.  
- AppBar with back button for nested screens.  
- All icons from Material Icons (outlined/filled variants).  
- Minimum touch target 48x48 logical pixels; Accessibility ≥ 4.5:1 contrast.  

## 🧪 Testing Matrix  
| Layer | Tool | Folder | Notes |
|------|------|--------|-------|
| Unit | flutter_test | `test/unit` | Test models, services, providers |
| Widget | flutter_test | `test/widget` | Test individual widgets |
| Integration | integration_test | `integration_test/` | End-to-end flows |

Coverage target ≥ 80% for `services/` and `providers/`.

## 🔄 Sync Workflow  
1. User action → local SQLite DB.  
2. Background sync observes connectivity; batches to Firebase.  
3. Conflicts resolved "last-write-wins with timestamp".  
4. Settings screen shows sync status: ✅ Synced or 🔄 Pending.  
Never block UI on network operations.

## ✨ Extension Points  
- **Feature flags** via SharedPreferences.  
- **Planned modules**: in-app analytics, push notifications. Keep services loosely-coupled.

## 🗣 Commit Style  
`<module>: <short imperative>`  
Example: `screens: add vaccine calendar view`.  
Run `flutter analyze` before committing.

## 🛡 Security & Privacy  
- Store sensitive data in FlutterSecureStorage.  
- Strip EXIF data from uploaded photos.  
- No file I/O outside app sandbox.

## 🚀 CI Hint  
If CI fails on dependencies, clear pub cache:  
```bash
flutter pub cache clean
flutter pub get
```

## 📝 Changelog Documentation
**MANDATORY**: After completing any changes:
1. Open `Changelog.md`
2. Add entry with format: `## [Date] - Topic`
3. List what was changed/added/removed
4. Save the file

***

### 🤖 Claude Usage Hints  
When asked to add/modify code:  
1. Search for existing widgets first.  
2. Generate focused changes; avoid touching unrelated files.  
3. Add documentation comments for public APIs.  
4. **ALWAYS** update Changelog.md after completing changes.  
5. End response with "// ready".

*(Update this CLAUDE.md after any structural or tooling change.)*