class OrderItem {
  String pid;
  String name;
  int quantity;
  double sellingPrice;
  double originalPrice;

  OrderItem({this.pid, this.name, this.quantity, this.sellingPrice, this.originalPrice});

  OrderItem.fromString(String productString) {
    List<String> components = productString.split('%');
    pid = components[0];
    name = components[1];
    quantity = int.parse(components[2]);
    sellingPrice = double.parse(components[3]);
    originalPrice = double.parse(components[4]);
  }

  String toDataString() {
    return '$pid%$name%$quantity%$sellingPrice%$originalPrice';
  }

  OrderItem combine(OrderItem item) {
    if(this.pid == item.pid) {
      this.quantity += item.quantity;
    }
    return this;
  }

  double get totalSellingPrice => sellingPrice * quantity;

  double get totalOriginalPrice => originalPrice * quantity;
}