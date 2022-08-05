import 'package:flutter/material.dart';

/// Menu opened when YOU DIE
class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  final String eventText = "a wave of goat hunter is coming ! :O";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: SizedBox(
        width: double.infinity,
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              flex: 8,
              child: Container(color: Colors.transparent),
            ),
            Expanded(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Text(
                    eventText,
                    style: const TextStyle(color: Colors.red, fontSize: 24),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(color: Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}
