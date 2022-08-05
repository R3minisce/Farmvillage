import 'package:flutter/material.dart';

class InventoryRow extends StatelessWidget {
  final Image icon;
  final int amount;

  const InventoryRow({
    required this.icon,
    Key? key,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.only(left: 16.0),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            SizedBox(child: icon),
            const SizedBox(width: 16),
            Text(
              amount.toString(),
              style: const TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
