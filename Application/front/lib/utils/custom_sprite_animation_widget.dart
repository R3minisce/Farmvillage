import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class CustomSpriteAnimationWidget extends StatelessWidget {
  final Future<SpriteAnimation> animation;

  const CustomSpriteAnimationWidget({Key? key, required this.animation})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: FutureBuilder(
        future: animation,
        builder: (context, data) {
          if (!data.hasData) return const SizedBox.shrink();
          return SpriteAnimationWidget(
            animation: data.data as SpriteAnimation,
          );
        },
      ),
    );
  }
}
