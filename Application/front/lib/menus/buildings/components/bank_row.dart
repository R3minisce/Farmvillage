import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/building_file.dart';
import 'package:front/models/item.dart';
import 'package:front/services/building_service.dart';
import 'package:front/utils/custom_sprite_animation_widget.dart';
import 'package:front/utils/spriteSheets/biquette_sprite_sheet.dart';

class BankRow extends StatelessWidget {
  const BankRow({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 8,
          child: Consumer(
            builder: (context, watch, _) {
              final responseAsyncValue = watch(getBankItemsProvider);
              return responseAsyncValue.map(
                data: (data) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.value.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ShopItem(data: data.value[index], watch: watch);
                    },
                  );
                },
                loading: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_) => const Center(
                  child: Text("An error occurred. Please try again later."),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShopItem extends StatelessWidget {
  const ShopItem({
    Key? key,
    required this.data,
    this.watch,
  }) : super(key: key);

  final Item data;
  final watch;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      width: 100,
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                data.label,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: 24.0,
              ),
              child: Center(
                child: CustomSpriteAnimationWidget(
                  animation: BiquetteSpriteSheet.runRight(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              child: Container(
                decoration: shadowBorder(8, 8, Colors.lightGreen),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      data.price.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8.0),
                    Image.asset(
                      "assets/images/items/gold.png",
                      height: 12,
                      width: 12,
                    ),
                  ],
                ),
              ),
              onTap: () async => _buyAlly(context),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              child: Container(
                decoration: shadowBorder(8, 8, Colors.blue.shade800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${data.price / 100} €",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8.0),
                    Image.asset(
                      "assets/other/paypal.png",
                      height: 16,
                      width: 16,
                    ),
                  ],
                ),
              ),
              onTap: () async => _testPaypal(context, data.id),
            ),
          ),
        ],
      ),
    );
  }

  _buyAlly(BuildContext context) async {
    var result = await BuildingService.buyAlly();
    if (result != null && result != false) {
      print("pas erreur");
    } else {
      //TODO
      print("erreur");
    }
  }

  _testPaypal(BuildContext context, String id) async {
    var amount = "1.0"; // reçevoir dynamiquement normalement

    var request = BraintreeDropInRequest(
        tokenizationKey: "sandbox_s9rvfx2n_s4t9nyhp2nnw8y9t",
        paypalRequest: BraintreePayPalRequest(
          amount: amount,
          displayName: 'FarmVillage',
          currencyCode: "EUR",
        ),
        collectDeviceData: true,
        cardEnabled: false);

    BraintreeDropInResult? res = await BraintreeDropIn.start(request);
    if (res != null) {
      var result = await BuildingService.buyItemPaypal(
          id, res.paymentMethodNonce.nonce, res.deviceData!);
      if (result) {
      } else {
        print("oskour 2");
      }
    } else {
      print("oskour");
    }
  }
}
