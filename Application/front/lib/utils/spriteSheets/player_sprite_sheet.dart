import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {
  static List<SpriteAnimationFrameData> spriteGenerator(
      int nbOfSprites, int offset) {
    return List<SpriteAnimationFrameData>.generate(
      nbOfSprites,
      (index) => SpriteAnimationFrameData(
          srcPosition: Vector2((32 * index).toDouble(), offset.toDouble()),
          srcSize: Vector2(32, 32),
          stepTime: 0.1),
    );
  }

  static Future<SpriteAnimation> attackEffectBottom() => SpriteAnimation.load(
        'player/attack_bottom.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> attackEffectLeft() => SpriteAnimation.load(
        'player/attack_left.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );
  static Future<SpriteAnimation> attackEffectRight() => SpriteAnimation.load(
        'player/attack_right.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );
  static Future<SpriteAnimation> attackEffectTop() => SpriteAnimation.load(
        'player/attack_top.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> idleLeft() => SpriteAnimation.load(
        'player/herosheet2.png',
        SpriteAnimationData([
          SpriteAnimationFrameData(
              srcPosition: Vector2((32.0 * 6), 0),
              srcSize: Vector2(32, 32),
              stepTime: 0.1),
          SpriteAnimationFrameData(
              srcPosition: Vector2((32.0 * 7), 0),
              srcSize: Vector2(32, 32),
              stepTime: 0.1),
          SpriteAnimationFrameData(
              srcPosition: Vector2((32.0 * 8), 0),
              srcSize: Vector2(32, 32),
              stepTime: 0.1),
          SpriteAnimationFrameData(
              srcPosition: Vector2((32.0 * 9), 0),
              srcSize: Vector2(32, 32),
              stepTime: 0.1)
        ]),
      );

  static Future<SpriteAnimation> idleRight() => SpriteAnimation.load(
        'player/herosheet.png',
        SpriteAnimationData(spriteGenerator(4, 0)),
      );

  static Future<SpriteAnimation> idleUp() => SpriteAnimation.load(
        'player/herosheet.png',
        SpriteAnimationData([
          SpriteAnimationFrameData(
              srcPosition: Vector2((32.0 * 1), 32.0 * 2),
              srcSize: Vector2(32, 32),
              stepTime: 0.4),
          SpriteAnimationFrameData(
              srcPosition: Vector2((32.0 * 5), 32.0 * 2),
              srcSize: Vector2(32, 32),
              stepTime: 0.4),
        ]),
      );

  static Future<SpriteAnimation> idleBot() => SpriteAnimation.load(
        'player/herosheet.png',
        SpriteAnimationData([
          SpriteAnimationFrameData(
              srcPosition: Vector2((32.0 * 1), 32.0 * 4),
              srcSize: Vector2(32, 32),
              stepTime: 0.4),
          SpriteAnimationFrameData(
              srcPosition: Vector2((32.0 * 5), 32.0 * 4),
              srcSize: Vector2(32, 32),
              stepTime: 0.4),
        ]),
      );

  static Future<SpriteAnimation> runLeft() => SpriteAnimation.load(
        'player/herosheet.png',
        SpriteAnimationData(spriteGenerator(8, 96)),
      );

  static Future<SpriteAnimation> runRight() => SpriteAnimation.load(
        'player/herosheet.png',
        SpriteAnimationData(spriteGenerator(8, 32)),
      );

  static Future<SpriteAnimation> runUp() => SpriteAnimation.load(
        'player/herosheet.png',
        SpriteAnimationData(spriteGenerator(8, 64)),
      );

  static Future<SpriteAnimation> runDown() => SpriteAnimation.load(
        'player/herosheet.png',
        SpriteAnimationData(spriteGenerator(8, 128)),
      );

  static SimpleDirectionAnimation playerAnimations() =>
      SimpleDirectionAnimation(
        idleLeft: idleLeft(),
        idleRight: idleRight(),
        idleDown: idleBot(),
        idleUp: idleUp(),
        runLeft: runLeft(),
        runRight: runRight(),
        runDown: runDown(),
        runUp: runUp(),
      );
}
