import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Helps to manage the collisions.
class SpawnArea extends GameDecoration {
  final String type;
  SpawnArea(Vector2 position, Size size, this.type)
      : super(
          position: position,
          width: size.width,
          height: size.height,
        );
}
