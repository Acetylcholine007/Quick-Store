import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_store/models/Product.dart';

import 'CellItem.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({Key key, this.product}) : super(key: key);

  DateTime getDateTime(String datetime) {
    List<int> values = datetime.split('-').map((value) => int.parse(value)).toList();
    return DateTime(values[0], values[1], values[2]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Badge(
      badgeContent: Text('Out of\nStock', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
      shape: BadgeShape.square,
      borderRadius: BorderRadius.circular(15),
      showBadge: product.quantity == 0,
      position: BadgePosition.topStart(top: 5, start: 5),
      child: Badge(
        badgeColor: product.isAboutToExpire() ? Colors.deepOrangeAccent : Colors.red,
        badgeContent: Text(product.isAboutToExpire() ? 'Soon to\nExpire' : 'Expired', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        shape: BadgeShape.square,
        borderRadius: BorderRadius.circular(15),
        showBadge: product.expiration != 'None' && (product.isAboutToExpire() || product.isExpired()),
        position: BadgePosition.topEnd(top: 5, end: 5),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                QrImage(
                    data: product.pid + '<=QuickStore=>' + product.pid,
                    version: QrVersions.auto,
                    size: 80
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.black, style: BorderStyle.solid)),
                    columnWidths: const <int, TableColumnWidth>{
                      0: IntrinsicColumnWidth(flex: 1),
                      1: IntrinsicColumnWidth(flex: 1),
                    },
                    children: [
                      TableRow(
                        children: [
                          CellItem(content: 'Product', align: TextAlign.left, style: theme.textTheme.bodyText2, padding: EdgeInsets.all(2)),
                          CellItem(content: product.name, align: TextAlign.left, style: theme.textTheme.bodyText2, padding: EdgeInsets.all(2)),
                        ]
                      ),
                      TableRow(
                          children: [
                            CellItem(content: 'Quantity', align: TextAlign.left, style: theme.textTheme.bodyText2, padding: EdgeInsets.all(2)),
                            CellItem(content: product.quantity.toString(), align: TextAlign.left, style: theme.textTheme.bodyText2, padding: EdgeInsets.all(2)),
                          ]
                      ),
                      TableRow(
                          children: [
                            CellItem(content: 'Item Profit', align: TextAlign.left, style: theme.textTheme.bodyText2, padding: EdgeInsets.all(2)),
                            CellItem(content: '??? ${(product.sellingPrice - product.originalPrice).toStringAsFixed(2)}', align: TextAlign.left, style: theme.textTheme.bodyText2, padding: EdgeInsets.all(2)),
                          ]
                      ),
                      TableRow(
                          children: [
                            CellItem(content: 'Total Profit', align: TextAlign.left, style: theme.textTheme.bodyText2, padding: EdgeInsets.all(2)),
                            CellItem(content: '??? ${((product.sellingPrice - product.originalPrice) * product.quantity).toStringAsFixed(2)}', align: TextAlign.left, style: theme.textTheme.bodyText2, padding: EdgeInsets.all(2)),
                          ]
                      ),
                    ],
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}
