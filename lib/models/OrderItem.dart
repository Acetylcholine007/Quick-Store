class OrderItem {
  String name;
  int quantity;
  double sellingPrice;
  double originalPrice;

  OrderItem({this.name, this.quantity, this.sellingPrice, this.originalPrice});

  OrderItem.fromString(String productString) {
    List<String> components = productString.split('%');
    name = components[0];
    quantity = int.parse(components[1]);
    sellingPrice = double.parse(components[2]);
    originalPrice = double.parse(components[3]);
  }

  String toDataString() {
    return '$name%$quantity%$sellingPrice%$originalPrice';
  }

  OrderItem combine(OrderItem item) {
    if(this.name == item.name) {
      this.quantity += item.quantity;
    }
    return this;
  }

  double get totalSellingPrice => sellingPrice * quantity;

  double get totalOriginalPrice => originalPrice * quantity;
}