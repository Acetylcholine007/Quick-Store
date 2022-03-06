import 'OrderItem.dart';

class Product {
  String pid;
  String name;
  double sellingPrice;
  int quantity;
  String expiration;
  double originalPrice;

  Product({this.pid, this.name = "", this.sellingPrice = 0, this.quantity = 0, this.expiration = "", this.originalPrice = 0});

  Product.fromLocalDB (Map<String, dynamic> fields) {
    Map<String, dynamic> newFields = fields;
    this.pid = newFields['pid'];
    this.name = newFields['name'];
    this.sellingPrice = newFields['sellingPrice'];
    this.quantity = newFields['quantity'];
    this.expiration = newFields['expiration'];
    this.originalPrice = newFields['originalPrice'];
  }

  Product.fromList(List row) {
    this.pid = row[0].toString();
    this.name = row[1].toString();
    this.sellingPrice = double.parse(row[2].toString());
    this.quantity = int.parse(row[3].toString());
    this.expiration = row[4].toString();
    this.originalPrice = double.parse(row[5].toString());
  }

  Map<String, dynamic> toMap() {
    return {
      'pid': this.pid,
      'name': this.name,
      'sellingPrice': this.sellingPrice,
      'quantity': this.quantity,
      'expiration': this.expiration,
      'originalPrice': this.originalPrice,
    };
  }

  OrderItem toOrderItem() {
    return OrderItem(name: this.name, quantity: 1, sellingPrice: this.sellingPrice, originalPrice: this.originalPrice);
  }

  List<String> toStringList() {
    return [
      this.pid,
      this.name,
      this.sellingPrice.toString(),
      this.quantity.toString(),
      this.expiration,
      this.originalPrice.toString()
    ];
  }

  static List<String> get headers => ['pid', 'name', 'sellingPrice', 'quantity', 'expiration', 'originalPrice'];
}