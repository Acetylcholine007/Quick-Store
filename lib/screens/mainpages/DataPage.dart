import 'package:flutter/material.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/services/DataService.dart';
import 'package:quick_store/shared/decorations.dart';

class DataPage extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;
  const DataPage({Key key, this.bloc, this.data}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool isLoading = false;

  void loadingHandler(bool status) {
    setState(() => isLoading = status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Color(0xFFF2E7E7),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        bottom: isLoading ? PreferredSize(
            preferredSize: Size(double.infinity, 1.0),
            child: LinearProgressIndicator(backgroundColor: Color(0xFF459A7C))
        ) : null,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('MANAGE DATA', textAlign: TextAlign.center, style: theme.textTheme.headline4.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
            ElevatedButton(
                onPressed: () => DataService.ds.exportInventory(context, loadingHandler, widget.data.products),
                child: Text('Export Inventory Data'),
                style: formButtonDecoration
            ),
            ElevatedButton(
                onPressed: () => DataService.ds.exportOrders(context, loadingHandler, widget.data.orders),
                child: Text('Export Orders Data'),
                style: formButtonDecoration
            ),
            ElevatedButton(
                onPressed: () => DataService.ds.printOrderToPDF(context, loadingHandler, widget.data.orders),
                child: Text('Generate PDF Report'),
                style: formButtonDecoration
            ),
            ElevatedButton(
                onPressed: () => DataService.ds.printQRCodes(context, loadingHandler, widget.data.products),
                child: Text('Print QR codes'),
                style: formButtonDecoration
            ),
            Divider(thickness: 1, height: 10),
            ElevatedButton(
                onPressed: () => DataService.ds.importInventory(context, loadingHandler, widget.bloc),
                child: Text('Import Inventory Data'),
                style: formButtonDecoration
            ),
            ElevatedButton(
                onPressed: () => DataService.ds.importOrders(context, loadingHandler, widget.bloc),
                child: Text('Import Orders Data'),
                style: formButtonDecoration
            ),
            ElevatedButton(
                onPressed: () => DataService.ds.mergeOrders(context, loadingHandler, widget.bloc),
                child: Text('Merge Orders Data'),
                style: formButtonDecoration
            ),
            Divider(thickness: 1, height: 10),
            ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                      AlertDialog(
                        title: Text('Clear Inventory Data'),
                        content: Text('Are you sure you want to delete your inventory data?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('NO')
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                DataService.ds.clearInventory(context, loadingHandler, widget.bloc);
                              },
                              child: Text('YES')
                          ),
                        ],
                      )
                    );
                  },
                child: Text('Clear Inventory Data'),
                style: formButtonDecoration
            ),
            ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                      AlertDialog(
                        title: Text('Clear Orders Data'),
                        content: Text('Are you sure you want to delete your orders data?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('NO')
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                DataService.ds.clearOrders(context, loadingHandler, widget.bloc);
                              },
                              child: Text('YES')
                          ),
                        ],
                      )
                  );
                },
                child: Text('Clear Orders Data'),
                style: formButtonDecoration
            ),
          ],
        ),
      ),
    );
  }
}
