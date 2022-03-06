import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_store/models/ProductData.dart';

import 'CellItem.dart';

class SummaryTab extends StatelessWidget {
  final DateTime datetime;
  final Map<String, ProductData> products;
  const SummaryTab({Key key, this.datetime, this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    products.values.forEach((el) => print(el.quantity));

    print(products.values.map((i) => i.totalSellingPrice).reduce((value, element) => value + element).toStringAsFixed(2));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            flex: 1,
            child: Center(child: Text('${DateFormat('MM/dd/yy').format(datetime)}\nSummary', style: theme.textTheme.bodyText1,))
        ),
        Expanded(
          flex:2,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder(horizontalInside: BorderSide(width: 1, color: theme.dividerColor, style: BorderStyle.solid)),
            columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(flex: 1),
              1: IntrinsicColumnWidth(flex: 2)
            },
            children: [
              TableRow(
                  children: [
                    CellItem(content: 'Revenue', align: TextAlign.left, style: theme.textTheme.bodyText1, padding: EdgeInsets.all(2)),
                    CellItem(content: '₱ ${
                        products.isNotEmpty ? products.values.map((i) => i.totalSellingPrice).reduce((value, element) => value + element).toStringAsFixed(2) : 0
                    }', align: TextAlign.right, style: theme.textTheme.bodyText1.copyWith(fontFamily: 'Roboto', color: Colors.black), padding: EdgeInsets.all(2)),
                  ]
              ),
              TableRow(
                  children: [
                    CellItem(content: 'Capital', align: TextAlign.left, style: theme.textTheme.bodyText1, padding: EdgeInsets.all(2)),
                    CellItem(content: '₱ ${
                        products.isNotEmpty ? products.values.map((i) => i.totalOriginalPrice).reduce((value, element) => value + element).toStringAsFixed(2) : 0
                    }', align: TextAlign.right, style: theme.textTheme.bodyText1.copyWith(fontFamily: 'Roboto', color: Colors.redAccent), padding: EdgeInsets.all(2)),
                  ]
              ),
              TableRow(
                  children: [
                    CellItem(content: 'Net Profit', align: TextAlign.left, style: theme.textTheme.bodyText1, padding: EdgeInsets.all(2)),
                    CellItem(content: '₱ ${
                        products.isNotEmpty ? products.values.map((i) => i.totalProfit).reduce((value, element) => value + element).toStringAsFixed(2) : 0
                    }', align: TextAlign.right, style: theme.textTheme.bodyText1.copyWith(fontFamily: 'Roboto', color: Color(0xFF459A7C)), padding: EdgeInsets.all(2)),
                  ]
              ),
            ],
          ),
        )
      ],
    );
  }
}
