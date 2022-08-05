import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;
  final Decoration borderFunc;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.color,
    required this.label,
    required this.textColor,
    required this.borderFunc,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: Container(
        //decoration: shadowBorder(32, 32, color),
        decoration: borderFunc,
        width: double.infinity,
        child: Material(
          type: MaterialType.transparency,
          elevation: 6.0,
          color: Colors.transparent,
          shadowColor: Colors.grey[50],
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(32.0)),
            splashColor:
                const Color.fromARGB(100, 75, 150, 230).withOpacity(0.6),
            onTap: onPressed,
            child: Align(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
