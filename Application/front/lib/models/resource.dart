import 'package:front/models/resource_type.dart';

class Resource {
  final ResourceType label;
  int quantity;
  final int maxQuantity;

  Resource(this.label, this.quantity, this.maxQuantity);
}
