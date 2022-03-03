class OrderItem {
  String name;
  int quantity;
  double price;

  OrderItem({this.name, this.quantity, this.price});

  OrderItem.fromString(String productString) {
    List<String> components = productString.split('%');
    name = components[0];
    quantity = int.parse(components[1]);
    price = double.parse(components[2]);
  }

  String toDataString() {
    return '$name%$quantity%$price';
  }

  OrderItem combine(OrderItem item) {
    if(this.name == item.name) {
      this.quantity += item.quantity;
    }
    return this;
  }

  double get totalPrice => price * quantity;
}