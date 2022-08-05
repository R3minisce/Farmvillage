import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Helps to manage the collisions.
class CollisionObject extends GameDecoration with ObjectCollision {
  CollisionObject(Vector2 position, Size size)
      : super(
          position: position,
          width: size.width,
          height: size.height,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: size,
            align: Vector2(32 * 0.2, 0),
          ),
        ],
      ),
    );
  }
}
