import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:flutter/material.dart';

/// Represents a big stone in the game.
class BigStoneRock extends GameDecoration with ObjectCollision {
  BigStoneRock(Vector2 position)
      : super.withSprite(
          Sprite.load('objects/stone.png'),
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

/// Represents a small stone in the game.
class SmallStoneRock extends GameDecoration with ObjectCollision {
  SmallStoneRock(Vector2 position)
      : super.withSprite(
          Sprite.load('objects/small_stone.png'),
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
