import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/keyboard_controller.dart';
import '../models/keyboard_layout.dart';
import '../models/key_model.dart';
import 'key_button.dart';

/// Pure key-rendering widget. Owns no position, no drag handle, no Material
/// wrapper — all of that lives in the overlay layer above it.
class KeyboardWidget extends ConsumerWidget {
  const KeyboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keyboardControllerProvider);
    if (!state.isVisible) return const SizedBox.shrink();

    final layout = KeyboardLayout.fromVariant(
      state.currentLayout,
      shortcuts: state.config.shortcuts,
    );

    return Directionality(
      textDirection: state.textDirection,
      child: Container(
        color: const Color(0xFFD1D5DB),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: layout.rows
              .map((row) => _buildRow(row, state.isUppercase, ref))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRow(List<KeyModel> row, bool isUppercase, WidgetRef ref) {
    return SizedBox(
      height: 50,
      child: Row(
        children: row.map((key) {
          if (key.type == KeyType.spacer) return Spacer(flex: key.flex);
          return KeyButton(
            keyModel: key,
            onTap: () =>
                ref.read(keyboardControllerProvider.notifier).onKeyTap(key),
            isUppercase: isUppercase,
          );
        }).toList(),
      ),
    );
  }
}
