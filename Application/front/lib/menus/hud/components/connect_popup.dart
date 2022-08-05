import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:front/components/icon_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/auth_type.dart';
import 'package:front/providers.dart';
import 'package:front/services/authentication_service.dart';

class ConnectPopup extends StatelessWidget {
  const ConnectPopup({
    Key? key,
    required this.name,
    required this.formKey,
    required this.label,
    required this.type,
  }) : super(key: key);

  final String name;
  final String label;
  final AuthType type;
  final GlobalKey<FormBuilderState> formKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: double.infinity,
        child: Container(
          margin: const EdgeInsets.all(48.0),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 1,
                child: Flex(direction: Axis.horizontal, children: [
                  Expanded(
                    flex: 9,
                    child: Text(
                      "Connect to $name",
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close,
                              color: Colors.red, size: 30)),
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Container(color: Colors.transparent),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  color: Colors.transparent,
                  child: FormBuilder(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: FormBuilderTextField(
                            name: "username",
                            validator: FormBuilderValidators.required(context),
                            decoration: InputDecoration(
                              filled: false,
                              labelText: label,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        Expanded(
                          flex: 5,
                          child: FormBuilderTextField(
                            name: "password",
                            validator: FormBuilderValidators.required(context),
                            obscureText: true,
                            decoration: const InputDecoration(
                              filled: false,
                              labelText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        Expanded(
                          flex: 3,
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(flex: 4, child: Container()),
                              Expanded(
                                flex: 1,
                                child: Consumer(
                                  builder: (context, watch, child) {
                                    return IconActionButton(
                                      color: Colors.white,
                                      iconColor: Colors.white,
                                      icon: Icons.check,
                                      borderFunc: shadowBorder(
                                        16,
                                        16,
                                        Colors.lime,
                                      ),
                                      onTap: () async =>
                                          _validateAction(type, context),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          decoration: shadowBorder(
            32,
            32,
            Colors.white,
          ),
        ),
      ),
    );
  }

  void _validateAction(AuthType type, BuildContext context) async {
    if (formKey.currentState!.saveAndValidate()) {
      var username = formKey.currentState!.value['username'];
      var password = formKey.currentState!.value['password'];

      dynamic res;
      var logins = Map.of(context.read(loginsProvider.notifier).state);

      switch (type) {
        case AuthType.BoomCraft:
          res = await AuthenticationService.loginBoomCraft(username, password);
          if (res != null) {
            var result = await AuthenticationService.linkExternal(
                res['pseudo'],
                res['mail'],
                type.toShortString(),
                res['id_user'].toString(),
                null,
                null,
                null);
            if (result) {
              logins[AuthType.BoomCraft] = true;
            }
          } else {}
          break;
        case AuthType.VeggieCrush:
          res =
              await AuthenticationService.loginVeggieCrush(username, password);
          if (res != null) {
            var result = await AuthenticationService.getProfilVeggieCrush(
                res['access_token']);
            if (result != null) {
              var result2 = await AuthenticationService.linkExternal(
                  result['username'],
                  null,
                  type.toShortString(),
                  result['id'].toString(),
                  res['refresh_token'],
                  null,
                  null);
              if (result2) {
                logins[AuthType.VeggieCrush] = true;
              }
            } else {}
          } else {}
          break;
        default:
      }

      if (res != null) {
        context.read(loginsProvider.notifier).state = logins;
        Navigator.of(context).pop();
      } else {
        // gérer pb de login
      }
    }
  }
}
