import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/icon_button.dart';
import 'package:front/components/input_field.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/resource.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/providers.dart';
import 'package:front/screens/rooms_screen.dart';
import 'package:front/services/authentication_service.dart';
import 'package:front/services/inventory_service.dart';
import 'package:front/sockets/socket_manager.dart';

class RegisterColumn extends StatelessWidget {
  RegisterColumn({
    Key? key,
  }) : super(key: key);

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 18,
      child: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "create your new account",
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
            const EmailRow(),
            const UsernameRow(),
            const PasswordRow(),
            const ConfirmRow(),
            ValidateRow(formKey: _formKey),
          ],
        ),
      ),
    );
  }
}

class EmailRow extends StatelessWidget {
  const EmailRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InputFieldCustom(
          name: 'email',
          color: Colors.black,
          textColor: Colors.black,
          hintLabel: "email",
          isSecret: false,
          isVisible: false,
          borderFunc: shadowBorder(
            32,
            32,
            Colors.white,
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.email(context),
            FormBuilderValidators.required(context),
          ]),
        ),
      ),
    );
  }
}

class UsernameRow extends StatelessWidget {
  const UsernameRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InputFieldCustom(
          name: 'username',
          color: Colors.black,
          textColor: Colors.black,
          hintLabel: "username",
          isSecret: false,
          isVisible: false,
          borderFunc: shadowBorder(
            32,
            32,
            Colors.white,
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.minLength(context, 5),
            FormBuilderValidators.maxLength(context, 20),
          ]),
        ),
      ),
    );
  }
}

class PasswordRow extends StatelessWidget {
  const PasswordRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Consumer(
          builder: (context, watch, child) {
            return Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: 8,
                  child: InputFieldCustom(
                    name: "password",
                    textColor: Colors.black,
                    color: Colors.white,
                    hintLabel: "password",
                    borderFunc: shadowBorder(32, 32, Colors.white),
                    isVisible: false,
                    isSecret: watch(visibilityProvider).state,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.match(context,
                          "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@\$%^&*-]).{12,}\$"),
                      FormBuilderValidators.required(context)
                    ]),
                    onChanged: (data) {
                      watch(passwordProvider.notifier).state = data!;
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: IconActionButton(
                    color: Colors.black,
                    iconColor: Colors.black,
                    icon: Icons.visibility,
                    borderFunc: shadowBorder(32, 32, Colors.white),
                    onTap: () => _changeVisibility(watch(visibilityProvider)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _changeVisibility(var visibility) {
    visibility.state = !visibility.state;
  }
}

class ConfirmRow extends StatelessWidget {
  const ConfirmRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Consumer(
          builder: (context, watch, child) {
            return InputFieldCustom(
              name: "confirmPassword",
              color: Colors.black,
              textColor: Colors.black,
              hintLabel: "confirm password",
              isSecret: watch(visibilityProvider).state,
              isVisible: false,
              borderFunc: shadowBorder(
                32,
                32,
                Colors.white,
              ),
              validator: (val) =>
                  _confirmPasswordValidator(watch(passwordProvider).state, val),
            );
          },
        ),
      ),
    );
  }

  String? _confirmPasswordValidator(
      String passwordValue, String? confirmPasswordValue) {
    if (confirmPasswordValue != passwordValue) {
      return "Passwords do not match.";
    }
  }
}

class ValidateRow extends StatelessWidget {
  const ValidateRow({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  final GlobalKey<FormBuilderState> formKey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 6,
              child: Container(),
            ),
            Expanded(
              flex: 4,
              child: Consumer(
                builder: (context, watch, child) {
                  return ActionButton(
                    color: Colors.black,
                    label: "validate",
                    textColor: Colors.white,
                    borderFunc: shadowBorder(
                        32, 32, const Color.fromARGB(200, 75, 150, 230)),
                    onPressed: () async => _register(
                      context,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _register(BuildContext context) async {
    if (formKey.currentState!.saveAndValidate()) {
      var email = formKey.currentState!.value['email'];
      var username = formKey.currentState!.value['username'];
      var password = formKey.currentState!.value['password'];

      var res = await AuthenticationService.register(username, email, password);
      if (res != null) {
        context.read(villagesProvider.notifier).state = res['villages'];
        var player = res['player'];
        var playerInventory = player['inventory'] as List;
        var playerResources = playerInventory
            .map((e) => Resource(ResourceTypeParsing.fromString(e['label'])!,
                e['quantity'], e['max_quantity']))
            .toList();
        context.read(inventoryProvider.notifier).state = playerResources;
        var socketManager = SocketManager();
        socketManager.connectToServer();
        socketManager.registerToken();
        Navigator.of(context).pop();
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                RoomsScreen(socketManager: socketManager),
          ),
        );
      } else {
        _showErrorSnackBar(context);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context) {
    var snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        'Username already used.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
