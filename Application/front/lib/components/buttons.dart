import 'package:flutter/material.dart';
import 'package:front/components/shadow_border.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 100,
      margin: const EdgeInsets.only(left: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: shadowBorder(4, 4, Colors.lime),
      child: InkWell(
        child: const Center(
          child: Text(
            "Yes :D",
            style: TextStyle(color: Colors.black),
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 100,
      margin: const EdgeInsets.only(left: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        child: const Center(
          child: Text(
            "No D:",
            style: TextStyle(color: Colors.red),
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(false);
        },
      ),
    );
  }
}
