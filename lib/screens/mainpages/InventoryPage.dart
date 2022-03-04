import 'package:flutter/material.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/NoItem.dart';
import 'package:quick_store/components/ProductTile.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/models/Product.dart';
import 'package:quick_store/screens/subpages/ItemEditor.dart';
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
  
  List<Product> filterProductHandler() {
    if(query == '') {
      return widget.data.products;
    } else {
      return widget.data.products.where(
        (product) => product.name.contains(new RegExp(query, caseSensitive: false))
      ).toList();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final products = filterProductHandler();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Color(0xFFE1DBDB),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                  'INVENTORY',
                  textAlign: TextAlign.left,
                  style: theme.textTheme.headline4.copyWith(color: Colors.black)
              )
            ),
            Expanded(
              flex: 1,
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
              )
            ),
            Expanded(
              flex: 10,
              child: products.isEmpty ? NoItem(label: 'No Products') : GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20
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
        onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ItemEditor(isNew: true, bloc: widget.bloc)),
          ),
      ),
    );
  }
}
