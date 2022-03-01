class Product {
  int pid;
  String name;
  double price;
  int quantity;
  String expiration;

  Product({this.pid, this.name, this.price, this.quantity, this.expiration});

  Product.fromLocalDB (Map<String, dynamic> fields) {
    Map<String, dynamic> newFields = fields;
    this.pid = newFields['pid'];
    this.name = newFields['name'];
    this.price = newFields['price'];
    this.quantity = newFields['quantity'];
    this.expiration = newFields['expiration'];
  }

  Map<String, dynamic> toMap() {
    return {'pid': this.pid, 'name': this.name, 'price': this.price, 'quantity': this.quantity, 'expiration': this.expiration};
  }
}