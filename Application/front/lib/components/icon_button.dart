import 'package:flutter/material.dart';

class IconActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final Decoration borderFunc;
  final VoidCallback onTap;

  const IconActionButton({
    Key? key,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.borderFunc,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
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
              onTap: onTap,
              child: Align(
                child: Icon(icon, color: iconColor),
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageActionButton extends StatelessWidget {
  final Decoration borderFunc;
  final VoidCallback onTap;
  final String image;

  const ImageActionButton({
    Key? key,
    required this.borderFunc,
    required this.onTap,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(2.0),
          decoration: borderFunc,
          width: double.infinity,
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            type: MaterialType.transparency,
            elevation: 6.0,
            color: Colors.transparent,
            shadowColor: Colors.grey[50],
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(32.0)),
              splashColor:
                  const Color.fromARGB(100, 75, 150, 230).withOpacity(0.6),
              onTap: onTap,
              child: Align(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(32.0),
                    child: Image.asset(image)),
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
