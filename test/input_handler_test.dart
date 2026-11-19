import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_keyboard/src/services/input_handler_service.dart';

void main() {
  group('InputHandlerService Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    test('insertText appends text when selection is empty', () {
      InputHandlerService.insertText(controller, 'Hello');
      expect(controller.text, 'Hello');
      expect(controller.selection.baseOffset, 5);
    });

    test('insertText replaces selection', () {
      controller.text = 'Hello World';
      controller.selection = const TextSelection(baseOffset: 6, extentOffset: 11);
      
      InputHandlerService.insertText(controller, 'Flutter');
      
      expect(controller.text, 'Hello Flutter');
      expect(controller.selection.baseOffset, 13);
    });

    test('backspace deletes character before cursor', () {
      controller.text = 'Hello';
      controller.selection = const TextSelection.collapsed(offset: 5);
      
      InputHandlerService.backspace(controller);
      
      expect(controller.text, 'Hell');
      expect(controller.selection.baseOffset, 4);
    });

    test('backspace deletes entire selection', () {
      controller.text = 'Hello World';
      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
      
      InputHandlerService.backspace(controller);
      
      expect(controller.text, ' World');
      expect(controller.selection.baseOffset, 0);
    });

    test('backspace handles emojis correctly', () {
      controller.text = 'Hello 👋';
      controller.selection = const TextSelection.collapsed(offset: 8);
      
      InputHandlerService.backspace(controller);
      
      expect(controller.text, 'Hello ');
      expect(controller.selection.baseOffset, 6);
    });
  });
}
