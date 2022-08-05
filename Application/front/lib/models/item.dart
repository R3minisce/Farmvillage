import 'package:front/models/item_type.dart';

class Item {
  final String id;
  final String label;
  final ItemType type;
  final String? description;
  final Target? target;
  final int? quantity;
  int ratio;
  int price;
  int duration;

  Item(this.id, this.label, this.type, this.description, this.target,
      this.ratio, this.price, this.duration, this.quantity);

  static Item fromJSON(data) {
    ItemType type = ItemTypeParsing.fromString(data['type'])!;
    Target? target = TargetParsing.fromString(data['target'] ?? "");
    num ratio = data['ratio'];
    num price = data['price'];
    num duration = data['duration'];
    num? quantity = data['quantity'];

    return Item(
        data['_id'].toString(),
        data['label'],
        type,
        data['description'],
        target,
        ratio.toInt(),
        price.toInt(),
        duration.toInt(),
        quantity?.toInt());
  }
}
