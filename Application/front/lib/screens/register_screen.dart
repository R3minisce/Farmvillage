import 'package:flutter/material.dart';
import 'package:front/components/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.dstIn),
            image: const AssetImage(
              "assets/other/map.png",
            ),
            fit: BoxFit.contain,
          ),
        ),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 40.0),
                alignment: Alignment.topCenter,
                child: Material(
                  shape: const CircleBorder(side: BorderSide(width: 2)),
                  color: Colors.transparent,
                  child: InkWell(
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 35,
                    ),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  RegisterColumn(),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
