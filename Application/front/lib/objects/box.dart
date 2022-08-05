import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:flutter/material.dart';
import 'package:front/models/resource_type.dart';

/// Box that can countain resources.
class Box extends GameDecoration with ObjectCollision {
  final ResourceType type;
  final String buildingId;

  Box(Vector2 position, this.type, this.buildingId)
      : super.withSprite(
          Sprite.load('objects/box.png'),
          position: position,
          width: 32,
          height: 46,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: const Size(32 * 0.6, 32 * 0.6),
            align: Vector2(32 * 0.2, 0),
          ),
        ],
      ),
    );
  }
}
