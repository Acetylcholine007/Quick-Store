import 'package:flutter/material.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/NoItem.dart';
import 'package:quick_store/components/ProductTile.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/models/Product.dart';
import 'package:quick_store/screens/subpages/ItemEditor.dart';
import 'package:quick_store/services/NotificationService.dart';
import 'package:quick_store/shared/decorations.dart';

class InventoryPage extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;

  const InventoryPage({Key key, this.bloc, this.data}) : super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String query = '';
  TextEditingController controller = TextEditingController();
  int productState = 0;
  
  List<Product> filterProductHandler(List<Product> products) {
    if(productState == 2) {
      products = products.where((product) => product.isExpired()).toList();
    } else if(productState == 1) {
      products = products.where((product) => product.isAboutToExpire()).toList();
    } else if(productState == 3) {
      products = products.where((product) => product.quantity == 0).toList();
    }

    if(query == '') {
      return products;
    } else {
      return products.where(
        (product) => product.name.contains(new RegExp(query, caseSensitive: false))
      ).toList();
    }
  }

  List<Product> sortProducts(List<Product> products) {
    products.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return products;
  }

  void onClickedNotification(String payload) {
    try {
      Product product = widget.data.products.singleWhere((element) => element.pid == payload);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ItemEditor(isNew: false, bloc: widget.bloc, product: product)),
      );
    } catch(e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    NotificationService.onNotifications.stream.listen(onClickedNotification);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final products = sortProducts(filterProductHandler(widget.data.products));

    return Scaffold(
      backgroundColor: theme.primaryColorLight,
      body: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'INVENTORY',
                    textAlign: TextAlign.left,
                    style: theme.textTheme.headline4.copyWith(color: Colors.black)
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField(
                    value: productState,
                    decoration: dropdownDecoration.copyWith(fillColor: theme.backgroundColor),
                    items: ['All', 'Soon to expire', 'Expired', 'Out of Stock'].asMap().entries.map((filter) => DropdownMenuItem(
                      value: filter.key,
                      child: Text(filter.value, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (value) => setState(() => productState = value),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16,  0, 16),
              child: Container(
                decoration: fieldContainerDecoration,
                child: TextFormField(
                  controller: controller,
                  decoration: searchFieldDecoration.copyWith(
                    suffixIcon: query == '' ? Icon(Icons.search_rounded) :
                    IconButton(onPressed: () {
                      controller.text = "";
                      setState(() => query = "");
                    }, icon: Icon(Icons.highlight_off_rounded))
                  ),
                  onChanged: (val) => setState(() => query = val),
                ),
              ),
            ),
            Expanded(
              child: products.isEmpty ? NoItem(label: 'No Products') : GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10
                ),
                itemCount: products.length,
                itemBuilder: (BuildContext context, index) {
                  return GestureDetector(
                      onTap: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ItemEditor(isNew: false, bloc: widget.bloc, product: products[index])),
                          ),
                      child: ProductTile(product: products[index])
                  );
                }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        // onPressed: () =>
            // NotificationService.showNotification(
            //     title: 'Candy',
            //     body: 'Candy is about to expired',
            //     payload: 'Candy Id'
            // )
        // NotificationService.showScheduledNotification(
        //   title: 'Candy',
        //   body: 'Candy is about to expired',
        //   payload: 'Candy Id',
        //   scheduleDate: DateTime.now().add(Duration(seconds: 10))
        // )
        onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemEditor(isNew: true, bloc: widget.bloc)),
          ),
      ),
    );
  }
}
