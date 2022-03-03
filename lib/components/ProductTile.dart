import 'package:flutter/material.dart';
import 'package:quick_store/models/Product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(product.name),
      decoration: BoxDecoration(
      color: Color(0xFFC4C4C4),
      borderRadius: BorderRadius.circular(15)),
    );
  }
}
