import 'package:flutter/material.dart';
import 'keyboard_layout.dart';

enum KeyboardType {
  text,
  multiline,
  number,
  phone,
  emailAddress,
  url,
  password,
  name,
  streetAddress,
}

enum LayoutVariant {
  qwerty,
  numeric,
  symbols,
  arabic,
  numberPad,
  phonePad,
}

class KeyboardConfig {
  final KeyboardType type;
  final LayoutVariant defaultLayout;
  final bool allowsSuggestions;
  final bool obscureText;
  final bool autoCapitalize;
  final String? allowedCharacters;
  final List<String> shortcuts;

  const KeyboardConfig({
    required this.type,
    required this.defaultLayout,
    this.allowsSuggestions = true,
    this.obscureText = false,
    this.autoCapitalize = true,
    this.allowedCharacters,
    this.shortcuts = const [],
  });

  factory KeyboardConfig.fromType(KeyboardType type) {
    switch (type) {
      case KeyboardType.text:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.qwerty,
        );
      case KeyboardType.multiline:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.qwerty,
        );
      case KeyboardType.number:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.numberPad,
          autoCapitalize: false,
          allowedCharacters: '0123456789.',
        );
      case KeyboardType.phone:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.phonePad,
          autoCapitalize: false,
          allowedCharacters: '0123456789+#*()-',
        );
      case KeyboardType.emailAddress:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.qwerty,
          autoCapitalize: false,
          shortcuts: ['@', '.'],
        );
      case KeyboardType.url:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.qwerty,
          autoCapitalize: false,
          shortcuts: ['/'],
        );
      case KeyboardType.password:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.qwerty,
          obscureText: true,
          allowsSuggestions: false,
          autoCapitalize: false,
        );
      case KeyboardType.name:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.qwerty,
          autoCapitalize: true,
        );
      case KeyboardType.streetAddress:
        return KeyboardConfig(
          type: type,
          defaultLayout: LayoutVariant.qwerty,
        );
    }
  }
}
