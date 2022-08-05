import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:flutter/material.dart';
import 'package:front/providers.dart';
import 'package:front/sockets/socket_manager.dart';

class Building extends GameDecoration
    with Attackable, ObjectCollision, Lighting {
  final String id;
  final Size originalSize;
  final bool mustBeVisible;
  final watch;
  final double resistance = 0.99;
  final Paint _barLiveBgPaint = Paint();
  final Paint _barLivePaint = Paint();
  final Paint _barLiveBorderPaint = Paint();

  Building(
    Vector2 position,
    String spriteSrc,
    this.originalSize,
    this.id,
    this.mustBeVisible,
    this.watch,
  ) : super.withSprite(
          Sprite.load(spriteSrc),
          position: position,
          width: mustBeVisible ? originalSize.width : 0,
          height: mustBeVisible ? originalSize.height : 0,
        ) {
    receivesAttackFrom = ReceivesAttackFromEnum.ENEMY;
    if (mustBeVisible) {
      setupCollision(
        CollisionConfig(
          collisions: [
            CollisionArea.rectangle(
              size: Size(originalSize.width, originalSize.height * 0.6),
              align: Vector2(0, originalSize.height * 0.4),
            ),
          ],
        ),
      );
      setupLighting(
        LightingConfig(radius: 0, blurBorder: 0, color: Colors.transparent),
      );
    }
    var map = watch(buildingsProvider.notifier).state as Map<String, Building>;
    map[id] = this;
  }

  build() {
    height = originalSize.height;
    width = originalSize.width;
    setupCollision(CollisionConfig(
      collisions: [
        CollisionArea.rectangle(
          size: Size(originalSize.width, originalSize.height * 0.6),
          align: Vector2(0, originalSize.height * 0.4),
        ),
      ],
    ));
    updateLighting();
  }

  updateLighting() {
    var isDay = watch(dayProvider).state;
    LightingConfig newConfig = (!isDay)
        ? LightingConfig(
            radius: width * 0.75,
            color: Colors.transparent,
            blurBorder: width * 0.75)
        : LightingConfig(radius: 0, color: Colors.transparent, blurBorder: 0);
    setupLighting(newConfig);
  }

  void updateLife(double hp, double maxHp) {
    initialLife(maxHp);
    life = hp;
  }

  @override
  void render(Canvas canvas) {
    drawDefaultLifeBar(
      canvas,
      height: 8,
      colorsLife: (maxLife > 0)
          ? [Colors.red, Colors.yellow, Colors.green]
          : [Colors.transparent],
      backgroundColor: (maxLife > 0) ? Colors.black : Colors.transparent,
      width: originalSize.width / 1.5,
      align: Offset(width / 6, 10),
      borderRadius: BorderRadius.circular(2),
    );
    super.render(canvas);
  }

  @override
  void receiveDamage(double damage, dynamic from) {
    if (damage > 0) {
      var damageCalculated = damage * (1 - resistance);
      SocketManager().emitBuildingReceiveDamage(id, damageCalculated);

      showDamage(
        damageCalculated,
        config: const TextPaintConfig(
          fontSize: 5,
          color: Colors.white,
          fontFamily: 'Normal',
        ),
      );
      super.receiveDamage(damageCalculated, from);
    }
  }

  void takeDamage(double damage, dynamic from) {
    if (damage > 0) {
      showDamage(
        damage,
        config: const TextPaintConfig(
          fontSize: 5,
          color: Colors.white,
          fontFamily: 'Normal',
        ),
      );
      super.receiveDamage(damage, from);
    }
  }

  void drawDefaultLifeBar(
    Canvas canvas, {
    Offset align = Offset.zero,
    bool drawInBottom = false,
    double margin = 4,
    double height = 4,
    double? width,
    List<Color>? colorsLife,
    Color backgroundColor = Colors.black,
    BorderRadius borderRadius = BorderRadius.zero,
    double borderWidth = 0,
    Color borderColor = Colors.white,
  }) {
    double yPosition = (position.top - height) - margin;

    double xPosition = position.left + align.dx;

    if (drawInBottom) {
      yPosition = position.bottom + margin;
    }

    yPosition = yPosition - align.dy;

    final w = width ?? position.width;

    double currentBarLife = (maxLife == 0) ? 0 : (life * w) / maxLife;

    if (borderWidth > 0) {
      final RRect borderRect = borderRadius.toRRect(Rect.fromLTWH(
        xPosition,
        yPosition,
        w,
        height,
      ));

      canvas.drawRRect(
        borderRect,
        _barLiveBorderPaint
          ..color = borderColor
          ..strokeWidth = borderWidth
          ..style = PaintingStyle.stroke,
      );
    }

    final RRect bgRect = borderRadius.toRRect(Rect.fromLTWH(
      xPosition,
      yPosition,
      w,
      height,
    ));

    canvas.drawRRect(
      bgRect,
      _barLiveBgPaint
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    final RRect lifeRect = borderRadius.toRRect(Rect.fromLTWH(
      xPosition,
      yPosition,
      currentBarLife,
      height,
    ));

    canvas.drawRRect(
      lifeRect,
      _barLivePaint
        ..color = _getColorLife(
          currentBarLife,
          w,
          colorsLife ?? [Colors.red, Colors.yellow, Colors.green],
        )
        ..style = PaintingStyle.fill,
    );
  }

  Color _getColorLife(
    double currentBarLife,
    double maxWidth,
    List<Color> colors,
  ) {
    final parts = maxWidth / colors.length;
    int index = (currentBarLife / parts).ceil() - 1;
    if (index < 0) {
      return colors[0];
    }
    if (index > colors.length - 1) {
      return colors.last;
    }
    return colors[index];
  }
}
