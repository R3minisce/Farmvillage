import 'dart:math';

import 'package:bonfire/bonfire.dart';

class TreeSpriteSheet {
  static Future<Sprite> getRandomTreeSprite() {
    Random random = Random();
    int index = random.nextInt(3) + 1;
    return Sprite.load('objects/tree$index.png');
  }
}