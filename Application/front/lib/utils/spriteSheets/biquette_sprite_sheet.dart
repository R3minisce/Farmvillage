import 'package:bonfire/bonfire.dart';

class BiquetteSpriteSheet {
  static List<SpriteAnimationFrameData> spriteGenerator(
      int nbOfSprites, int offset) {
    return List<SpriteAnimationFrameData>.generate(
      nbOfSprites,
      (index) => SpriteAnimationFrameData(
          srcPosition: Vector2((48 * index).toDouble(), offset.toDouble()),
          srcSize: Vector2(48, 48),
          stepTime: 0.1),
    );
  }

  static Future<SpriteAnimation> runDown() => SpriteAnimation.load(
        'enemies/biquette/biquette.png',
        SpriteAnimationData(spriteGenerator(3, 0)),
      );

  static Future<SpriteAnimation> runLeft() => SpriteAnimation.load(
        'enemies/biquette/biquette.png',
        SpriteAnimationData(spriteGenerator(3, 48)),
      );

  static Future<SpriteAnimation> runRight() => SpriteAnimation.load(
        'enemies/biquette/biquette.png',
        SpriteAnimationData(spriteGenerator(3, 96)),
      );

  static Future<SpriteAnimation> runTop() => SpriteAnimation.load(
        'enemies/biquette/biquette.png',
        SpriteAnimationData(spriteGenerator(3, 144)),
      );

  static SimpleDirectionAnimation biquetteAnimations() =>
      SimpleDirectionAnimation(
          idleLeft: runLeft(),
          idleRight: runRight(),
          runLeft: runLeft(),
          runRight: runRight(),
          runUp: runTop(),
          runDown: runDown());
}
