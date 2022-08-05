import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/providers.dart';

class HpBar extends StatelessWidget {
  const HpBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        var hp = watch(hpProvider).state;
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
                  flex: hp.toInt(),
                  child: Container(
                    decoration: shadowBorder(
                      16,
                      16,
                      Colors.redAccent.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1000 - hp.toInt(),
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
