import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/CellItem.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/models/OrderItem.dart';

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
          products[orderItem.name] = products[orderItem.name].combine(
              ProductData(orderItem.quantity, orderItem.price)
          );
        } else {
          products[orderItem.name] = ProductData(orderItem.quantity, orderItem.price);
        }
      });
    });

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: (widget.isAll ? <Widget>[] : <Widget>[
          Expanded(
            flex: 1,
            child: Text('Daily Tally', style: theme.textTheme.headline6)
        )]) + <Widget>[
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
            flex: 10,
            child: products.isNotEmpty ? SingleChildScrollView(
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
                    CellItem(content: product.key, align: TextAlign.left, style: theme.textTheme.bodyText1),
                    CellItem(content: product.value.quantity.toString(), align: TextAlign.left, style: theme.textTheme.bodyText1),
                    CellItem(content: product.value.totalPrice.toStringAsFixed(2), align: TextAlign.left, style: theme.textTheme.bodyText1),
                  ]
                )).toList(),
              ),
            ) : Center(child: Text('No Orders at\n${DateFormat('MMMM dd, yyyy').format(getDateTime())}', style: theme.textTheme.headline4, textAlign: TextAlign.center)),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(DateFormat('MM/dd/yy').format(getDateTime())),
                Text('Total = ₱ ${
                  products.isNotEmpty ? products.values.map((i) => i.quantity * i.price).reduce((value, element) => value + element).toStringAsFixed(2) : 0
                }', style: theme.textTheme.headline6.copyWith(color: Colors.red))
              ],
            ),
          ),
        ] + (widget.isAll ? <Widget>[Expanded(
            flex: 1,
            child: ElevatedButton(onPressed: () {
              showDatePicker(
                  context: context,
                  initialDate: getDateTime(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (BuildContext context, Widget child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        // primaryColor: const Color(0xFFF2E7E7),
                        colorScheme: ColorScheme.light(primary: theme.primaryColor),
                        buttonTheme: ButtonThemeData(
                            textTheme: ButtonTextTheme.primary
                        ),
                      ),
                      child: child,
                    );
                  }
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
            }, child: Text('Pick Date'))
        )] : <Widget>[]),
      ),
    );
  }
}

class ProductData {
  int quantity;
  double price;

  ProductData(this.quantity, this.price);

  double get totalPrice => price * quantity;

  ProductData combine (ProductData item) {
    this.quantity += item.quantity;
    this.price += item.price;
    return this;
  }
}
