import 'package:flutter/material.dart';

class InputHandlerService {
  static void insertText(TextEditingController controller, String text) {
    final currentText = controller.text;
    final selection = controller.selection;

    final newText = currentText.replaceRange(
      selection.start != -1 ? selection.start : currentText.length,
      selection.end != -1 ? selection.end : currentText.length,
      text,
    );

    final newSelection = TextSelection.collapsed(
      offset: (selection.start != -1 ? selection.start : currentText.length) + text.length,
    );

    controller.value = controller.value.copyWith(
      text: newText,
      selection: newSelection,
    );
  }

  static void backspace(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start == 0 && selection.end == 0) return;

    String newText;
    int newOffset;

    if (selection.start != selection.end) {
      newText = text.replaceRange(selection.start, selection.end, '');
      newOffset = selection.start;
    } else {
      // Use characters to handle emojis and special characters correctly
      final characters = text.characters;
      if (characters.isEmpty) return;

      final startOffset = selection.start;
      final textBefore = text.substring(0, startOffset);
      final textAfter = text.substring(startOffset);

      if (textBefore.isEmpty) return;

      final charactersBefore = textBefore.characters;
      final newTextBefore = charactersBefore.skipLast(1).toString();
      
      newText = newTextBefore + textAfter;
      newOffset = newTextBefore.length;
    }

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  static void moveCursor(TextEditingController controller, int delta) {
    final selection = controller.selection;
    final text = controller.text;

    int newOffset = selection.extentOffset + delta;
    if (newOffset < 0) newOffset = 0;
    if (newOffset > text.length) newOffset = text.length;

    controller.selection = TextSelection.collapsed(offset: newOffset);
  }
}
