import 'package:flutter/material.dart';

BoxDecoration shadowBorder(double leftRadius, double rightRadius, Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.horizontal(
        left: Radius.circular(leftRadius), right: Radius.circular(rightRadius)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ],
  );
}
