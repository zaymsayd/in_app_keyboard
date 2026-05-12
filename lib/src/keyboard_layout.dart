/// Keyboard type passed to [InAppTextField.keyboardType].
enum InAppKeyboardType {
  number,
  decimal,
  phone,
  qwerty,
  qwertyUppercase,
  email;

  List<List<String>> get layout {
    switch (this) {
      case InAppKeyboardType.number:         return InAppKeyboardLayout.numberPad;
      case InAppKeyboardType.decimal:        return InAppKeyboardLayout.numeric;
      case InAppKeyboardType.phone:          return InAppKeyboardLayout.phonePad;
      case InAppKeyboardType.qwerty:         return InAppKeyboardLayout.qwerty;
      case InAppKeyboardType.qwertyUppercase: return InAppKeyboardLayout.qwertyUppercase;
      case InAppKeyboardType.email:          return InAppKeyboardLayout.email;
    }
  }
}

/// Predefined layouts for the InAppKeyboard.
///
/// Use '' as an empty spacer cell and ' ' for the space key.
class InAppKeyboardLayout {
  /// Standard 3-column numeric with decimal (matches iOS decimalPad).
  static const List<List<String>> numeric = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  /// Pure number pad — no decimal (matches iOS numberPad).
  /// The leading '' is a transparent spacer so 0 is centred.
  static const List<List<String>> numberPad = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '⌫'],
  ];

  /// Phone dial-pad layout (matches iOS phonePad / Android phone).
  static const List<List<String>> phonePad = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['*', '0', '#'],
    ['', '⌫', '+'],
  ];

  /// Lowercase QWERTY with space bar (matches default text keyboard).
  static const List<List<String>> qwerty = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm', '⌫'],
    [',', ' ', '.', '↵'],
  ];

  /// Uppercase QWERTY with space bar.
  static const List<List<String>> qwertyUppercase = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
    [',', ' ', '.', '↵'],
  ];

  /// Email-optimised QWERTY — adds @, common punctuation, and .com shortcut.
  static const List<List<String>> email = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm', '⌫'],
    ['@', '.', '-', '_', '.com'],
  ];

  /// Wider numeric layout suitable for large screens (tablet / desktop).
  static const List<List<String>> numericLarge = [
    ['1', '2', '3', '4', '5'],
    ['6', '7', '8', '9', '0'],
    ['.', '⌫'],
  ];
}
