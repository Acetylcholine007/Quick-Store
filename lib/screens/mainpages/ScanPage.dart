import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/SummarySheet.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/models/Order.dart';
import 'package:quick_store/models/Product.dart';
import 'package:quick_store/models/ProductItem.dart';
import 'package:uuid/uuid.dart';

class ScanPage extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;

  const ScanPage({Key key, this.bloc, this.data}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Map<String, ProductItem> productItems = {};
  List<String> productKeys = [];
  bool isProcessing = false;

  void orderHandler() async {
    var uuid = Uuid();
    Map<String, int> newQuantity = {};
    List<String> orderItemStrings = productItems.values.map((item) => item.orderItem.toDataString()).toList();
    productItems.forEach((key, value) => newQuantity[key] = value.quantity - value.orderItem.quantity);

    Order order = Order(
        oid: uuid.v1(),
        datetime: DateTime.now().toString(),
        itemString: orderItemStrings.reduce((value, element) => '${value};$element')
    );

    String result = await widget.bloc.addOrder(order, newQuantity);

  if(result == 'SUCCESS') {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Order recorded'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );
    setState(() {
      productItems = {};
      isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Recording Order'),
          content: Text(result),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK')
            )
          ],
        )
    );
  }
  }

  void abortHandler() async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Order canceled'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );
    setState(() {
      productItems = {};
      isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<ScanResponse> scanHandler() async {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        List<String> data =
        result.rawContent.contains('<=QuickStore=>')
            ? result.rawContent.split('<=QuickStore=>')
            : null;
        if (data != null && data[0] == data[1]) {
          Product product = widget.data.products.firstWhere((product) => product.pid == data[0]);

          if (product != null) {
            return ScanResponse(product, 'SUCCESS');
          } else {
            return ScanResponse(null, 'Product does not exist');
          }
        } else {
          return ScanResponse(null, 'Invalid QR code content');
        }
      } else {
        return ScanResponse(null, 'Failed to scan QR code');
      }
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: isProcessing ? SummarySheet(products: productItems, orderHandler: orderHandler, abortHandler: abortHandler) : Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Scan QR Code', style: theme.textTheme.headline4.copyWith(color: Colors.black)),
          Column(
            children: [
              IconButton(
                iconSize: 80,
                icon: Icon(Icons.radio_button_checked_rounded),
                onPressed: () async {
                  var status = await Permission.camera.status;

                  if (status.isDenied) {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Scan QR Code'),
                        content: Text('Scanning QR code requires allowing the app to use the phone\'s camera.'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK')
                          )
                        ],
                      )
                    );
                    await Permission.camera.request();
                    status = await Permission.camera.status;
                  }

                  if(status.isGranted) {
                    ScanResponse response = await scanHandler();
                    if(response.result != 'SUCCESS') {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Scan QR Code'),
                            content: Text(response.result),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK')
                              )
                            ],
                          )
                      );
                    }

                    showDialog(
                      context: context,
                      builder: (context) {
                        Map<String, ProductItem> localProductItems = response.result == 'SUCCESS' ?
                        {response.product.pid: ProductItem(response.product.toOrderItem(), response.product.quantity)} : {};
                        String productIndex = response.result == 'SUCCESS' ? response.product.pid : '';

                        return StatefulBuilder(
                          builder: (context, localSetState) {
                            void processScan() async {
                              ScanResponse response = await scanHandler();
                              if(response.result == 'SUCCESS') {
                                localSetState(() {
                                  if(localProductItems[response.product.pid] != null) {
                                    localProductItems[response.product.pid] =
                                        ProductItem(
                                            localProductItems[response.product.pid].orderItem.combine(response.product.toOrderItem()),
                                            response.product.quantity
                                        );
                                  } else {
                                    localProductItems[response.product.pid] = ProductItem(
                                        response.product.toOrderItem(),
                                        response.product.quantity
                                    );
                                  }
                                  productIndex = response.product.pid;
                                });
                              }
                              // else {
                              //   showDialog(
                              //       context: context,
                              //       builder: (context) => AlertDialog(
                              //         title: Text('Scan QR Code'),
                              //         content: Text(response.result),
                              //         actions: [
                              //           TextButton(
                              //               onPressed: () {
                              //                 Navigator.pop(context);
                              //               },
                              //               child: Text('OK')
                              //           )
                              //         ],
                              //       )
                              //   );
                              // }
                            }

                            return AlertDialog(
                              contentPadding: EdgeInsets.all(0),
                              // title: Text("Scan Products"),
                              content: localProductItems.isNotEmpty ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Name: ${localProductItems[productIndex].orderItem.name}\n'
                                                'Quantity: ${localProductItems[productIndex].orderItem.quantity}\n'
                                                'Price: ${(localProductItems[productIndex].orderItem.totalPrice).toStringAsFixed(2)}',
                                            style: theme.textTheme.bodyText1,
                                          )
                                        ),
                                        IconButton(onPressed: () => localSetState(() => localProductItems[productIndex].orderItem.quantity++), icon: Icon(Icons.arrow_drop_up_rounded)),
                                        IconButton(onPressed: () => localSetState(() => localProductItems[productIndex].orderItem.quantity--), icon: Icon(Icons.arrow_drop_down_rounded)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                  color: Colors.black, width: 1
                                              ),
                                              right: BorderSide(
                                                  color: Colors.black, width: 1
                                              ),
                                            )
                                          ),
                                          child: Center(
                                            child: TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    productItems = localProductItems;
                                                    productKeys = productItems.keys.toList();
                                                    isProcessing = true;
                                                  });
                                                },
                                                child: Text('DONE', style: TextStyle(color: Colors.red))
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                    color: Colors.black, width: 1
                                                ),
                                              )
                                          ),
                                          child: Center(
                                            child: TextButton(
                                                onPressed: processScan,
                                                child: Text(localProductItems.isNotEmpty ? 'NEXT' : 'SCAN', style: TextStyle(color: Colors.black))
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ) : Text('No product'),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Scan QR Code'),
                        content: Text('Camera permission denied'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK')
                          )
                        ],
                      )
                    );
                  }
                },
              ),
              Text('CAPTURE', style: theme.textTheme.bodyText1)
            ],
          )
        ],
      ),
    );
  }
}

class ScanResponse {
  Product product;
  String result;
  ScanResponse(this.product, this.result);
}