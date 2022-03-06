import 'package:quick_store/models/ProductData.dart';

import 'OrderItem.dart';

class ProductItem {
  OrderItem orderItem;
  int quantity;

  ProductItem(this.orderItem, this.quantity);

  ProductData toProductData() {
    return ProductData(orderItem.quantity, orderItem.sellingPrice, orderItem.originalPrice);
  }
}