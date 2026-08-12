# AGENTS.md

## Project State

Freshly scaffolded Flutter counter app. No game code exists yet.

- Dart SDK constraint: `^3.12.2` (in `pubspec.yaml`). This is a version floor, not a pinned version. Do not assume a specific installed Flutter version.
- No FVM configuration present.
- No CI, task runner, or pre-commit hooks configured.

## Actual File Layout

Only two source files exist right now:

- `lib/main.dart` (counter scaffold, untouched)
- `test/widget_test.dart` (counter smoke test, untouched)

There are no subdirectories under `lib/` beyond `main.dart`. No `lib/game/`, `lib/components/`, `lib/screens/`, `lib/models/`, or `assets/` directories exist.

## README Is Aspirational

The `README.md` describes a planned Flame-based educational game. The project structure diagram, Flame engine mention, assets folders, and `lib/{game,components,screens,models}` layout are future plans, not current reality. Do not treat the README as a faithful description of what exists on disk.

## Flame Is Not a Dependency

Flame does not appear in `pubspec.yaml`. Before any code can import or use Flame:

1. Run `flutter pub add flame`
2. Then `flutter pub get`

Do not add Flame import statements before the dependency is installed.

## Linting

`analysis_options.yaml` includes only `package:flutter_lints/flutter.yaml` with all rule overrides commented out. No custom lint rules or analyzer settings are active. The lint set is stock Flutter defaults.

## Commands

```bash
flutter pub get          # install/refresh dependencies
flutter analyze          # run static analysis (flutter_lints defaults)
flutter test             # run tests (currently one counter test)
dart format .            # format all Dart files
```

## Test File

`test/widget_test.dart` contains the default counter increment smoke test. It asserts `'0'` and `'1'` text and taps the `Icons.add` button. This test will break as soon as `lib/main.dart` is changed away from the counter UI. Replace it with a test that matches whatever home screen replaces the counter.

## What to Do When Starting Development

1. Replace the counter UI in `lib/main.dart` with the actual game entry point.
2. Replace `test/widget_test.dart` to match the new home screen.
3. Add Flame to `pubspec.yaml` before importing it anywhere.
4. Create `lib/game/`, `lib/components/`, `lib/screens/`, `lib/models/`, and `assets/` directories as needed.
