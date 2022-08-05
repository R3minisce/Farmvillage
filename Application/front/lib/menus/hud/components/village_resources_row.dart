import 'package:flutter/material.dart';

class VillageResourcesRow extends StatelessWidget {
  final Image icon;
  final int amount;
  final int maxAmount;

  const VillageResourcesRow({
    required this.icon,
    required this.amount,
    this.maxAmount = -1,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0),
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.end,
        direction: Axis.horizontal,
        children: [
          Container(child: icon),
          const SizedBox(width: 16),
          Text(
            amount.toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
          ),
          if (maxAmount != -1)
            Text(
              " / $maxAmount",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14.0, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
