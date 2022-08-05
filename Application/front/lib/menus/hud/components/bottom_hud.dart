import 'package:flutter/material.dart';

class BottomHUD extends StatelessWidget {
  const BottomHUD({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        color: Colors.transparent,
      ),
    );
  }
}
