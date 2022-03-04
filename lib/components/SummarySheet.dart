import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_store/models/ProductItem.dart';

import 'CellItem.dart';

class SummarySheet extends StatelessWidget {
  final Map<String, ProductItem> products;
  final Function orderHandler;
  final Function abortHandler;
  const SummarySheet({Key key, this.products, this.orderHandler, this.abortHandler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
            flex: 1,
            child: Text('Order Summary', style: theme.textTheme.headline6)
        ),
        Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: CellItem(content: 'Product', align: TextAlign.center, style: theme.textTheme.bodyText1)
                ),
                Expanded(
                  flex: 1,
                  child: CellItem(content: 'Quantity', align: TextAlign.center, style: theme.textTheme.bodyText1),
                ),
                Expanded(
                  flex: 1,
                  child: CellItem(content: 'Price', align: TextAlign.center, style: theme.textTheme.bodyText1),
                ),
              ],
            )
        ),
        Expanded(
          flex: 8,
          child: SingleChildScrollView(
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.all(color: Colors.black, width: 1),
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(flex: 2),
                1: IntrinsicColumnWidth(flex: 1),
                2: IntrinsicColumnWidth(flex: 1),
              },
              children: products.entries.map((product) => TableRow(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  children: [
                    CellItem(content: product.value.orderItem.name, align: TextAlign.left, style: theme.textTheme.bodyText1),
                    CellItem(content: product.value.orderItem.quantity.toString(), align: TextAlign.left, style: theme.textTheme.bodyText1),
                    CellItem(content: product.value.orderItem.totalPrice.toStringAsFixed(2), align: TextAlign.left, style: theme.textTheme.bodyText1),
                  ]
              )).toList(),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(DateFormat('MM/dd/yy').format(DateTime.now())),
              Text('Total = ₱ ${
                  products.isNotEmpty ? products.values.map((i) => i.orderItem.quantity * i.orderItem.price)
                      .reduce((value, element) => value + element).toStringAsFixed(2) : 0
              }', style: theme.textTheme.headline6.copyWith(color: Colors.red))
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: orderHandler, child: Text('CONFIRM')),
              ElevatedButton(onPressed: abortHandler, child: Text('CANCEL')),
            ],
          ),
        )
      ],
    );
  }
}
