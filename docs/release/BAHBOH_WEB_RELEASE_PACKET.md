# Bahboh Web Release Packet

## Scope
- Target: web only
- Path: `/bahboh/`
- Project URL: `https://bcaris-rn.github.io/bahboh/`
- Status: local package prepared; hosted Pages evidence not yet collected

## Build
- Command: `flutter build web --release --base-href /bahboh/`
- Artifact: `build/web`
- Notes: Flutter web build completed successfully with the project base path set for GitHub Pages

## Validation
- `flutter pub get`: passed
- `flutter analyze`: passed
- `flutter test`: passed
- `flutter run -d chrome`: passed

## Smoke Notes
- App boots into the Bahboh pre-round overlay
- Active bubble drag, lock, annihilation, pause/resume, restart, and scoring are covered by tests and the current runtime
- Chrome launch succeeded and terminated cleanly

## Deferred Targets
- Desktop
- Android
- iOS
- Backend
- Auth
- Cloud save
- Monetization
- Multiplayer
- Ambient music system

## Known Limitations
- Hosted GitHub Pages evidence is not yet verified from the live URL
- Cross-browser QA has not been collected beyond Chrome
- Audio and haptics remain stubbed and browser-safe by design

## Readiness Label
- Local release candidate, web-bounded, not yet published
