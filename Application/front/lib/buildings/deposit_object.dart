import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/objects/box.dart';

/// Helps to manage the interactivity with the boxes - zones to deposit.
class DepositObject extends GameDecoration {
  int resources = 0;
  final String id;
  List<Box> boiboites = [];

  DepositObject(Vector2 position, Size size, this.id)
      : super(
          position: position,
          width: size.width,
          height: size.height,
        );

  handleBox(ResourceType type, int storage) {
    if (boiboites.length > storage / 100) {
      gameRef.remove(boiboites[0]);
      boiboites.removeAt(0);
    }
    if (boiboites.length < storage / 100) {
      Random r = Random();
      var x = position.rect.topCenter.dx + r.nextDouble() * 50;
      var y = position.rect.topCenter.dy + r.nextDouble() * 50;
      var boiboite = Box(Vector2(x, y), type, id);
      boiboites.add(boiboite);
      gameRef.add(boiboite);
    }
  }
}
