import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/providers.dart';

class StaminaBar extends StatelessWidget {
  const StaminaBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        var stamina = watch(staminaProvider).state;
        return Expanded(
          child: Container(
            decoration: shadowBorder(
              16,
              16,
              Colors.black.withOpacity(0.2),
            ),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: stamina.toInt(),
                  child: Container(
                    decoration: shadowBorder(
                      16,
                      16,
                      Colors.lightGreen,
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - stamina.toInt(),
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
