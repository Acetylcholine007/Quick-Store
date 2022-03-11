import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/CellItem.dart';
import 'package:quick_store/components/SummaryTab.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/models/OrderItem.dart';
import 'package:quick_store/models/ProductData.dart';
import 'package:quick_store/shared/decorations.dart';

class DailyTallyPage extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;
  final bool isAll;

  const DailyTallyPage({Key key, this.bloc, this.data, this.isAll}) : super(key: key);

  @override
  _DailyTallyPageState createState() => _DailyTallyPageState();
}

class _DailyTallyPageState extends State<DailyTallyPage> {
  String dateToday = DateTime.now().toString().split(' ')[0];

  DateTime getDateTime() {
    List<int> values = dateToday.split('-').map((value) => int.parse(value)).toList();
    return DateTime(values[0], values[1], values[2]);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, ProductData> products = {};
    final theme = Theme.of(context);

    widget.data.orders.where((order) => order.datetime.split(' ')[0] == dateToday).forEach((order) {
      List<String> orderItemStrings = order.itemString.split(';').toList();
      orderItemStrings.forEach((itemString) {
        OrderItem orderItem = OrderItem.fromString(itemString);
        if(products[orderItem.name] != null) {
          if(products[orderItem.name].sellingPrice == orderItem.sellingPrice && products[orderItem.name].originalPrice == orderItem.originalPrice) {
            products[orderItem.name] = products[orderItem.name].combine(
                ProductData(orderItem.quantity, orderItem.sellingPrice, orderItem.originalPrice)
            );
          } else {
            products[orderItem.name] = ProductData(orderItem.quantity, orderItem.sellingPrice, orderItem.originalPrice);
          }
        } else {
          products[orderItem.name] = ProductData(orderItem.quantity, orderItem.sellingPrice, orderItem.originalPrice);
        }
      });
    });

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CellItem(content: 'Product', align: TextAlign.center, style: theme.textTheme.bodyText1)
                  ),
                  Expanded(
                    flex: 1,
                    child: CellItem(content: 'Qty', align: TextAlign.center, style: theme.textTheme.bodyText1),
                  ),
                  Expanded(
                    flex: 2,
                    child: CellItem(content: 'Price', align: TextAlign.center, style: theme.textTheme.bodyText1),
                  ),
                  Expanded(
                    flex: 2,
                    child: CellItem(content: 'Profit', align: TextAlign.center, style: theme.textTheme.bodyText1),
                  ),
                ],
              )
          ),
          Expanded(
            flex: 10,
            child: products.isNotEmpty ? SingleChildScrollView(
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(color: Colors.black, width: 1),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(flex: 3),
                  1: IntrinsicColumnWidth(flex: 1),
                  2: IntrinsicColumnWidth(flex: 2),
                  3: IntrinsicColumnWidth(flex: 2),
                },
                children: products.entries.map((product) => TableRow(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  children: [
                    CellItem(content: product.key, align: TextAlign.left, style: theme.textTheme.bodyText1),
                    CellItem(content: product.value.quantity.toString(), align: TextAlign.left, style: theme.textTheme.bodyText1),
                    CellItem(content: product.value.totalSellingPrice.toStringAsFixed(2), align: TextAlign.left, style: theme.textTheme.bodyText1),
                    CellItem(content: product.value.totalProfit.toStringAsFixed(2), align: TextAlign.left, style: theme.textTheme.bodyText1),
                  ]
                )).toList(),
              ),
            ) : Center(child: Text('No Orders at\n${DateFormat('MMMM dd, yyyy').format(getDateTime())}', style: theme.textTheme.headline4, textAlign: TextAlign.center)),
          ),
          Divider(thickness: 1, height: 10),
          SummaryTab(datetime: getDateTime(), products: products),
        ] + (widget.isAll ? <Widget>[ElevatedButton(onPressed: () {
          showDatePicker(
              context: context,
              initialDate: getDateTime(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
          )
              .then((pickedDate) {
            if (pickedDate == null) {
              return;
            }
            setState(() {
              print(pickedDate.toString().split(' ')[0]);
              dateToday = pickedDate.toString().split(' ')[0];
            });
          });
        }, child: Text('Pick Date'), style: formButtonDecoration)] : <Widget>[]),
      ),
    );
  }
}
