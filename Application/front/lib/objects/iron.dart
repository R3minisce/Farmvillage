import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:flutter/material.dart';

/// Represents a big iron in the game.
class BigIronRock extends GameDecoration with ObjectCollision {
  BigIronRock(Vector2 position)
      : super.withSprite(
          Sprite.load('objects/iron.png'),
          position: Vector2(position.x, position.y),
          width: 70,
          height: 70,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: const Size(70, 30),
            align: Vector2(0, 30),
          ),
        ],
      ),
    );
  }
}

/// Represents a small iron in the game.
class SmallIronRock extends GameDecoration with ObjectCollision {
  SmallIronRock(Vector2 position)
      : super.withSprite(
          Sprite.load('objects/small_iron.png'),
          position: Vector2(position.x, position.y),
          width: 35,
          height: 35,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: const Size(35, 15),
            align: Vector2(0, 15),
          ),
        ],
      ),
    );
  }
}
