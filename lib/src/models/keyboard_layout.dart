import 'key_model.dart';
import 'keyboard_config.dart';

class KeyboardLayout {
  final List<List<KeyModel>> rows;
  final LayoutVariant variant;

  const KeyboardLayout({
    required this.rows,
    required this.variant,
  });

  static KeyboardLayout fromVariant(LayoutVariant variant, {List<String> shortcuts = const []}) {
    switch (variant) {
      case LayoutVariant.qwerty:
        return _qwerty(shortcuts);
      case LayoutVariant.numeric:
        return _numeric(shortcuts);
      case LayoutVariant.symbols:
        return _symbols();
      case LayoutVariant.arabic:
        return _arabic(shortcuts);
      case LayoutVariant.numberPad:
        return _numberPad();
      case LayoutVariant.phonePad:
        return _phonePad();
    }
  }

  static KeyboardLayout _qwerty(List<String> shortcuts) => KeyboardLayout(
        variant: LayoutVariant.qwerty,
        rows: [
          _buildRow(['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']),
          _buildRow(['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l']),
          [
            const KeyModel.action(label: 'Shift', action: KeyAction.shift, flex: 1),
            ..._buildRow(['z', 'x', 'c', 'v', 'b', 'n', 'm']),
            const KeyModel.action(label: 'Delete', action: KeyAction.backspace, flex: 1),
          ],
          [
            const KeyModel.action(label: '123', action: KeyAction.switchLayout, actionPayload: LayoutVariant.numeric, flex: 2),
            const KeyModel.action(label: '🌐', action: KeyAction.language, flex: 1),
            if (shortcuts.isNotEmpty) ...shortcuts.where((s) => s != '.').map((s) {
              return KeyModel(
                label: s,
                value: s,
              );
            }),
            const KeyModel.action(label: 'Space', action: KeyAction.space, flex: 4),
            if (shortcuts.contains('.')) 
              const KeyModel(
                label: '.',
                value: '.',
                alternates: ['.com', '.org', '.net', '.edu'],
              ),
            const KeyModel.action(label: 'Enter', action: KeyAction.enter, flex: 2),
          ],
        ],
      );

  static KeyboardLayout _symbols() => KeyboardLayout(
        variant: LayoutVariant.symbols,
        rows: [
          _buildRow(['[', ']', '{', '}', '#', '%', '^', '*', '+', '=']),
          _buildRow(['_', '\\\\', '|', '~', '<', '>', '\$', '€', '£', '¥']),
          [
            const KeyModel.action(label: '123', action: KeyAction.switchLayout, actionPayload: LayoutVariant.numeric, flex: 1),
            ..._buildRow(['.', ',', '?', '!', '\'']),
            const KeyModel.action(label: 'Delete', action: KeyAction.backspace, flex: 1),
          ],
          [
            const KeyModel.action(label: 'ABC', action: KeyAction.switchLayout, actionPayload: LayoutVariant.qwerty, flex: 2),
            const KeyModel.action(label: 'Space', action: KeyAction.space, flex: 5),
            const KeyModel.action(label: 'Enter', action: KeyAction.enter, flex: 2),
          ],
        ],
      );

  static KeyboardLayout _numeric(List<String> shortcuts) => KeyboardLayout(
        variant: LayoutVariant.numeric,
        rows: [
          _buildRow(['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']),
          _buildRow(['-', '/', ':', ';', '(', ')', '\$', '&', '@', '"']),
          [
            const KeyModel.action(label: '#+=', action: KeyAction.switchLayout, actionPayload: LayoutVariant.symbols, flex: 1),
            KeyModel(
              label: '.',
              value: '.',
              alternates: shortcuts.contains('@') ? ['.com', '.org', '.net', '.edu'] : null,
            ),
            ..._buildRow([',', '?', '!', '\'']),
            const KeyModel.action(label: 'Delete', action: KeyAction.backspace, flex: 1),
          ],
          [
            const KeyModel.action(label: 'ABC', action: KeyAction.switchLayout, actionPayload: LayoutVariant.qwerty, flex: 2),
            if (shortcuts.isNotEmpty) ...shortcuts.where((s) => s != '@').map((s) => KeyModel(label: s, value: s)),
            const KeyModel.action(label: 'Space', action: KeyAction.space, flex: 4),
            const KeyModel.action(label: 'Enter', action: KeyAction.enter, flex: 2),
          ],
        ],
      );

  static KeyboardLayout _arabic(List<String> shortcuts) => KeyboardLayout(
        variant: LayoutVariant.arabic,
        rows: [
          _buildRow(['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج', 'د']),
          _buildRow(['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط']),
          [
            const KeyModel.action(label: 'Delete', action: KeyAction.backspace, flex: 1),
            ..._buildRow(['ئ', 'ء', 'ؤ', 'ر', 'لا', 'ى', 'ة', 'و', 'ز', 'ظ']),
            const KeyModel.action(label: 'Shift', action: KeyAction.shift, flex: 1),
          ],
          [
            const KeyModel.action(label: '123', action: KeyAction.switchLayout, actionPayload: LayoutVariant.numeric, flex: 2),
            const KeyModel.action(label: '🌐', action: KeyAction.language, flex: 1),
            if (shortcuts.isNotEmpty) ...shortcuts.where((s) => s != '.').map((s) => KeyModel(label: s, value: s)),
            const KeyModel.action(label: 'Space', action: KeyAction.space, flex: 4),
            if (shortcuts.contains('.')) 
              const KeyModel(
                label: '.',
                value: '.',
                alternates: ['.com', '.org', '.net', '.edu'],
              ),
            const KeyModel.action(label: 'Enter', action: KeyAction.enter, flex: 2),
          ],
        ],
      );

  static KeyboardLayout _numberPad() => KeyboardLayout(
        variant: LayoutVariant.numberPad,
        rows: [
          _buildRow(['1', '2', '3']),
          _buildRow(['4', '5', '6']),
          _buildRow(['7', '8', '9']),
          [
            const KeyModel(label: '.', value: '.', alternates: [',']),
            const KeyModel(label: '0', value: '0'),
            const KeyModel.action(label: 'Delete', action: KeyAction.backspace),
          ],
        ],
      );

  static KeyboardLayout _phonePad() => KeyboardLayout(
        variant: LayoutVariant.phonePad,
        rows: [
          _buildRow(['1', '2', '3']),
          _buildRow(['4', '5', '6']),
          _buildRow(['7', '8', '9']),
          [
            const KeyModel(label: '+', value: '+'),
            const KeyModel(label: '0', value: '0', alternates: ['+']),
            const KeyModel.action(label: 'Delete', action: KeyAction.backspace),
          ],
        ],
      );

  static List<KeyModel> _buildRow(List<String> keys) {
    return keys.map((k) => KeyModel(label: k, value: k)).toList();
  }
}
