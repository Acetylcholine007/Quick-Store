import 'package:quick_store/models/Product.dart';
import 'package:quick_store/models/Order.dart';

class LocalDBDataPack {
  List<Product> products;
  List<Order> orders;
  bool hasProducts;
  bool hasOrders;

  LocalDBDataPack({this.products, this.orders, this.hasProducts, this.hasOrders});
}