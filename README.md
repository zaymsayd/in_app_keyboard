# in_app_keyboard

[![pub package](https://img.shields.io/pub/v/in_app_keyboard.svg)](https://pub.dev/packages/in_app_keyboard)
[![pub points](https://img.shields.io/pub/points/in_app_keyboard)](https://pub.dev/packages/in_app_keyboard/score)
[![popularity](https://img.shields.io/pub/popularity/in_app_keyboard)](https://pub.dev/packages/in_app_keyboard/score)
[![likes](https://img.shields.io/pub/likes/in_app_keyboard)](https://pub.dev/packages/in_app_keyboard/score)

A Flutter package for replacing the system keyboard with a fully custom in-app keyboard — built for tablets, POS terminals, and any app where the native keyboard gets in the way.

## Platform Support

| Android | iOS |
|:-------:|:---:|
| ✅      | ✅  |

---

## Overview

The system keyboard works fine for consumer apps. For kiosk-style apps, POS systems, or anything running on a fixed large screen, it's a constant frustration: it resizes your layout unexpectedly, you can't control its appearance, and on tablets it floats in a position that makes no sense for your UI.

This package sidesteps all of that by rendering the keyboard entirely within your app, using Flutter's overlay system. The native keyboard never appears. You get full control over layout, position, and behavior.

It's not a virtual keyboard that wraps `TextField` with extra logic — every `InAppTextField` is `readOnly: true` at the Flutter level, and all text input is handled through a central `KeyboardController` that manages state via Riverpod.

---

## Features

**Keyboard**
- Nine keyboard types: text, number, phone, email, URL, password, multiline, name, street address
- Shift with auto-off after one character; double-tap shift for caps lock
- Hold backspace for continuous deletion
- Long-press keys to show alternates (e.g. `.` → `.com`, `.org`, `.net`, `.edu`)
- Haptic feedback on key press, long-press, and alternate selection

**Layouts**
- QWERTY (upper and lower case)
- Numeric with punctuation
- Symbols
- Number pad (iOS-style 3×3)
- Phone pad (with `*`, `#`, `+`)
- Arabic (RTL, full script)

**Large screen support**
- Floating draggable keyboard activates automatically on screens ≥600px wide
- Drag anywhere, stays within screen bounds, position persists across the session
- Bottom-docked mode for phones

**Architecture**
- Overlay-based — keyboard renders above your widget tree, no layout shifts
- Riverpod state management with `keepAlive: true`
- Each field registers and unregisters with the keyboard controller on focus

---

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_keyboard: ^0.0.1
```

Since this package uses Riverpod code generation, run the build runner once after adding the dependency:

```bash
flutter pub get
dart run build_runner build
```

**Wrap your app with `ProviderScope` and `KeyboardOverlay`:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_keyboard/in_app_keyboard.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [InAppKeyboardObserver()],
      builder: (context, child) {
        return KeyboardOverlay(child: child!);
      },
      home: const HomeScreen(),
    );
  }
}
```

`KeyboardOverlay` must sit above your entire widget tree. Placing it in the `MaterialApp` builder is the right spot — it gives the overlay access to the full screen, including areas that would otherwise be obscured by the system keyboard.

> **Important:** Since this is a custom overlay keyboard, set `resizeToAvoidBottomInset: false` on your `Scaffold` widgets. This prevents Flutter from trying to resize the layout for a system keyboard that never appears.

```dart
Scaffold(
  resizeToAvoidBottomInset: false,
  body: ...
)
```

### Automatic Scrolling

On small screens where the keyboard docks at the bottom, `KeyboardOverlay` automatically adds `AnimatedPadding` to push your content up. `InAppTextField` also automatically triggers `Scrollable.ensureVisible` after the keyboard appears to ensure the focused field is never covered. For the best experience, wrap your scrollable content in a `SingleChildScrollView`.

---

## Basic Usage

Replace your `TextField` with `InAppTextField`:

```dart
import 'package:in_app_keyboard/in_app_keyboard.dart';

InAppTextField(
  controller: myController,
  decoration: const InputDecoration(
    labelText: 'Full name',
    border: OutlineInputBorder(),
  ),
  keyboardType: KeyboardType.name,
  onChanged: (value) => print(value),
  onSubmitted: (value) => handleSubmit(value),
)
```

The keyboard opens when the field gains focus and closes when it loses focus. Everything else — layout selection, shift state, text insertion — is handled internally.

`InAppTextField` accepts most of the same parameters as Flutter's `TextField`:

```dart
InAppTextField(
  controller: controller,
  decoration: decoration,
  keyboardType: KeyboardType.text,     // controls keyboard behavior
  layout: LayoutVariant.qwerty,        // override the default layout for this type
  focusNode: focusNode,
  autofocus: false,
  obscureText: true,                   // password masking
  maxLines: 1,
  minLines: 1,
  maxLength: 100,
  inputFormatters: [...],
  textCapitalization: TextCapitalization.none,
  textInputAction: TextInputAction.next,
  onChanged: (v) {},
  onSubmitted: (v) {},
  enabled: true,
  style: TextStyle(fontSize: 16),
)
```

---

## Keyboard Types

`KeyboardType` describes the intent of the field, which determines the default layout and any restrictions on allowed characters.

| Type | Default layout | Notes |
|---|---|---|
| `text` | QWERTY | General text input |
| `multiline` | QWERTY | Enter key inserts newline |
| `number` | Number pad | Allows `0–9` and `.` |
| `phone` | Phone pad | Allows `0–9`, `#`, `*`, `+`, `(`, `)`, `-` |
| `emailAddress` | QWERTY | Bottom row includes `@` and `.` shortcuts |
| `url` | QWERTY | Bottom row includes `/` shortcut |
| `password` | QWERTY | Obscures text, disables suggestions |
| `name` | QWERTY | Auto-capitalizes |
| `streetAddress` | QWERTY | Standard text, no special behavior |

The `layout` parameter on `InAppTextField` lets you override the default layout for any type — for example, showing a numeric layout for a field typed as `text`.

---

## Layout Variants

`LayoutVariant` is the visual layout, independent of the keyboard type:

- `qwerty` — standard four-row QWERTY with shift, backspace, and a bottom row for space and enter
- `numeric` — ten digits plus common punctuation (decimal numbers, currency)
- `symbols` — special characters, brackets, operators
- `numberPad` — iOS-style 3×3 grid with decimal and zero
- `phonePad` — iOS-style phone layout with `*`, `0`, `#`, and `+`
- `arabic` — full Arabic script in RTL direction

The Arabic layout automatically sets `TextDirection.rtl` on the text field.

---

## Large Screen / Floating Keyboard

On any screen 600px wide or wider, the keyboard switches to floating mode automatically. There's nothing to configure — it detects the screen size when a field registers.

The floating keyboard is a 460×260px panel with a drag handle at the top. You can drag it anywhere on screen; it clamps to the screen bounds so it can't be dragged off-edge. The position is remembered for the duration of the session.

The drag handle bar shows the current keyboard type label on the left and a close button on the right. Tapping the close button hides the keyboard without removing focus.

If you need to force floating mode programmatically:

```dart
final controller = ref.read(keyboardControllerProvider.notifier);
controller.toggleFloating(true);
```

On phones, the keyboard docks to the bottom of the screen. By default, tapping outside the keyboard area dismisses it:

```dart
KeyboardOverlay(
  dismissOnOutsideTap: true,  // default: true
  child: child,
)
```

---

## Customization

**Override the layout for a specific field:**

```dart
InAppTextField(
  keyboardType: KeyboardType.text,
  layout: LayoutVariant.arabic,
)
```

**Access the keyboard controller directly:**

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboardState = ref.watch(keyboardControllerProvider);
    final controller = ref.read(keyboardControllerProvider.notifier);

    return ElevatedButton(
      onPressed: controller.hide,
      child: const Text('Dismiss keyboard'),
    );
  }
}
```

`keyboardControllerProvider` exposes the full `KeyboardState` — current visibility, active layout, shift state, floating position, and the active `TextEditingController`.

**Long-press alternates** are defined per key in the layout via `KeyModel.alternates`. For example, the `.` key on the email layout includes `['.com', '.org', '.net', '.edu']` by default. Custom layouts can define any alternates on any key.

---

## Navigation & Auto-Dismiss

The keyboard hides automatically when the user navigates between routes. Three options — pick one.

**Option 1 — `InAppKeyboardObserver` (recommended)**

Works with standard `Navigator`, GoRouter, GetX, AutoRoute, and any router that calls the Flutter navigator under the hood.

```dart
MaterialApp(
  navigatorObservers: [InAppKeyboardObserver()],
  ...
)
```

Hides the keyboard on every push, pop, replace, or remove. No per-screen setup required.

**Option 2 — `keyboardRouteObserver` + `InAppKeyboardRouteAware` mixin**

For fine-grained control per screen. Register the observer globally:

```dart
MaterialApp(
  navigatorObservers: [keyboardRouteObserver],
  ...
)
```

Then use the mixin on any screen state that should auto-hide the keyboard:

```dart
class _MyScreenState extends State<MyScreen> with RouteAware, InAppKeyboardRouteAware {
  // Mixin handles subscribe/unsubscribe and hide automatically.
}
```

**Option 3 — Manual**

```dart
ref.read(keyboardControllerProvider.notifier).hide();
```

---

## Architecture Notes

The package has two main moving parts:

**`InAppTextField`** is a `ConsumerStatefulWidget` that wraps a standard Flutter `TextField` with `readOnly: true`. When it receives focus, it calls `keyboardControllerProvider.notifier.registerField()`, passing its `TextEditingController`, the requested `KeyboardType`, and an optional `LayoutVariant` override. When it loses focus, it calls `unregisterField()`.

**`KeyboardOverlay`** sits at the top of the widget tree and listens to `keyboardControllerProvider`. When `isVisible` becomes true, it inserts a keyboard widget into Flutter's overlay. On phones this is a bottom-docked sheet; on tablets it's the floating panel. When `isVisible` becomes false, it removes the overlay entry.

All text mutation goes through `InputHandlerService`, which handles cursor-aware insertion, selection replacement, and multi-byte backspace (so emoji deletion works correctly).

The Riverpod provider uses `keepAlive: true`, meaning the keyboard state survives navigation — the same keyboard instance is reused across all screens.

---

## Limitations

- **Theming is not yet exposed.** Key colors, background color, and font styles are currently hardcoded in the widget layer. A `KeyboardTheme` API is planned.
- **This is a pre-release (0.0.1).** The public API may change before a stable release.
- **No web support.** The overlay architecture and `readOnly` field approach rely on mobile/desktop Flutter behavior. Web is not currently tested or supported.
- **`build_runner` is required.** The Riverpod provider uses code generation (`@Riverpod` annotation). If you skip `dart run build_runner build`, the package won't compile.
- **System autofill does not work.** Since fields are `readOnly: true` at the Flutter level, platform autofill (passwords, addresses) is not available. This is an inherent tradeoff of the approach.

---

## Roadmap

- Themeable keyboard (`KeyboardTheme` parameter on `KeyboardOverlay`)
- Custom layout builder API — pass a full `KeyboardLayout` to `InAppTextField`
- Swipe-to-dismiss for the floating panel
- Transition animations for keyboard show/hide
- Additional language layouts

---

## License

MIT. See [LICENSE](LICENSE) for details.
