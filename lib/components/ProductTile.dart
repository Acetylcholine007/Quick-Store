import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_store/models/Product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          QrImage(
              data: product.pid + '<=QuickStore=>' + product.pid,
              version: QrVersions.auto,
              size: 80
          ),
          Text(product.name, style: theme.textTheme.bodyText2, overflow: TextOverflow.ellipsis),
        ],
      ),
      decoration: BoxDecoration(
      color: Color(0xFFC4C4C4),
      borderRadius: BorderRadius.circular(15)),
    );
  }
}
