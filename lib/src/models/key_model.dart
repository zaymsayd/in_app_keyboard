import 'package:flutter/material.dart';

enum KeyType {
  alpha,
  numeric,
  symbol,
  action,
  spacer,
}

enum KeyAction {
  none,
  backspace,
  shift,
  capsLock,
  enter,
  space,
  switchLayout,
  language,
  dismiss,
}

class KeyModel {
  final String label;
  final String? value;
  final KeyType type;
  final KeyAction action;
  final dynamic actionPayload;
  final IconData? icon;
  final int flex;
  final List<String>? alternates;

  const KeyModel({
    required this.label,
    this.value,
    this.type = KeyType.alpha,
    this.action = KeyAction.none,
    this.actionPayload,
    this.icon,
    this.flex = 1,
    this.alternates,
  });

  const KeyModel.spacer({this.flex = 1})
      : label = '',
        value = null,
        type = KeyType.spacer,
        action = KeyAction.none,
        actionPayload = null,
        icon = null,
        alternates = null;

  const KeyModel.action({
    required this.label,
    required this.action,
    this.actionPayload,
    this.icon,
    this.flex = 1,
    this.alternates,
  })  : value = null,
        type = KeyType.action;
}
