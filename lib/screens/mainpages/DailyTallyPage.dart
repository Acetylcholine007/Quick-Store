import 'package:flutter/material.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/models/OrderItem.dart';

class DailyTallyPage extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;

  const DailyTallyPage({Key key, this.bloc, this.data}) : super(key: key);

  @override
  _DailyTallyPageState createState() => _DailyTallyPageState();
}

class _DailyTallyPageState extends State<DailyTallyPage> {
  Map<String, ProductData> products = {};

  @override
  void initState() {
    super.initState();

    widget.data.orders.forEach((order) {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print(products);
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Text('Daily Tally', style: theme.textTheme.headline6)
          ),
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(color: Colors.black, width: 1),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(flex: 2),
                  1: IntrinsicColumnWidth(flex: 1),
                  2: IntrinsicColumnWidth(flex: 1),
                },
                children: [
                  TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Product', style: theme.textTheme.headline6),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Quantity', style: theme.textTheme.headline6),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Price', style: theme.textTheme.headline6),
                        ),
                      ]
                  )
                ] + products.entries.map((product) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(product.key, style: theme.textTheme.headline6),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(product.value.quantity.toString(), style: theme.textTheme.headline6),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(product.value.totalPrice.toString(), style: theme.textTheme.headline6),
                      ),
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
                Text(DateTime.now().toString()),
                Text('Total = ${
                  products.values.map((i) => i.quantity * i.price).reduce((value, element) => value + element)
                }')
              ],
            ),
          )
        ],
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