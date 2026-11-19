## 0.0.1

Initial release.

- Nine keyboard types: `text`, `number`, `phone`, `emailAddress`, `url`, `password`, `multiline`, `name`, `streetAddress`
- Six layout variants: `qwerty`, `numeric`, `symbols`, `numberPad`, `phonePad`, `arabic`
- Floating draggable keyboard on screens ≥600px wide; bottom-docked on phones
- Long-press key alternates (e.g. `.` → `.com`, `.org`, `.net`, `.edu`)
- Shift with auto-off; double-tap for caps lock; hold backspace for continuous deletion
- Haptic feedback on key press, long-press, and alternate selection
- Arabic RTL layout with automatic `TextDirection.rtl`
- `InAppKeyboardObserver` for automatic keyboard dismissal on navigation
- `InAppKeyboardRouteAware` mixin for per-screen dismissal control
- Emoji-safe multi-byte backspace via `InputHandlerService`
- Riverpod `keepAlive` provider — keyboard state survives navigation
