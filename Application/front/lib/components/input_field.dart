import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';

class InputFieldCustom extends StatelessWidget {
  final Color color;
  final String name;
  final String hintLabel;
  final Color textColor;
  final Decoration borderFunc;
  final bool isVisible;
  final bool isSecret;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;

  const InputFieldCustom({
    Key? key,
    required this.name,
    required this.color,
    required this.hintLabel,
    required this.textColor,
    required this.borderFunc,
    required this.isVisible,
    required this.isSecret,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: Container(
        decoration: borderFunc,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: name,
                  validator: validator,
                  obscureText: isSecret,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintLabel,
                    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                  ),
                  style: TextStyle(color: textColor, fontSize: 20.0),
                ),
              ),
              Visibility(
                  child: Icon(
                    Icons.search,
                    color: textColor,
                  ),
                  visible: isVisible)
            ],
          ),
        ),
      ),
    );
  }
}
