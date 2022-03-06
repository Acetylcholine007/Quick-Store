import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/Order.dart';
import 'package:quick_store/models/Product.dart';
import 'package:share/share.dart';

class DataService {
  DataService._();

  static final DataService ds = DataService._();

  Future<bool> cameraPermissionHandler (BuildContext context) async {
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

    if(status.isGranted) return true;
    else return false;
  }

  Future<bool> writePermissionHandler (BuildContext context) async {
    var status = await Permission.storage.status;

    if (status.isDenied) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Save QR Code'),
          content: Text('Saving QR code image requires allowing the app to use the phone\'s storage.'),
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
      await Permission.storage.request();
      status = await Permission.storage.status;
    }

    if(status.isGranted) return true;
    else return false;
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)
    );
  }

  Future<bool> downloadQRImage(BuildContext context, Product product) async {
    final qrValidationResult = QrValidator.validate(
      data: product.pid + '<=QuickStore=>' + product.pid,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    final qrCode = qrValidationResult.qrCode;

    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const Color(0xFF000000),
      emptyColor: Colors.white,
      gapless: true,
      embeddedImageStyle: null,
      embeddedImage: null,
    );

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String path = '$tempPath/${product.name}.png';

    final picData = await painter.toImageData(2048,
        format: ui.ImageByteFormat.png);
    await writeToFile(picData, path);

    return await GallerySaver.saveImage(path);
  }

  Future<String> qrPrintHandler(BuildContext context, List<Product> products) async {
    var status = await DataService.ds.writePermissionHandler(context);

    if(status) {
      String result = 'FAILED';
      await Future.wait(products.map((product) => downloadQRImage(context, product)))
      .then((value) {
        bool output = value.reduce((value, element) => value && element);
        if(output) {
          result = 'SUCCESS';
        } else {
          result = 'Some products failed to export';
        }
      })
      .catchError((err) => result = err.toString());
      return result;
    } else {
      return 'Write Permission denied';
    }
  }

  void exportInventory(BuildContext context, Function loadingHandler, List<Product> products) async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Inventory Data ready to be shared'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    loadingHandler(true);
    try {
      List<List<String>> newProducts = [Product.headers];

      products.forEach((product) {
        newProducts.add(product.toStringList());
      });

      String csvData = ListToCsvConverter().convert(newProducts);
      String directory  = (await getTemporaryDirectory()).path;
      final path = "$directory/QuickStore_Inventory_${DateTime.now()}.csv";
      final File file = File(path);
      File csvFile = await file.writeAsString(csvData);

      if(csvFile != null) {
        Share.shareFiles([csvFile.path],
            text: 'QuickStore Inventory', subject: 'QuickStore Inventory Data');
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch(e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Export Inventory'),
            content: Text(e.toString()),
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
    loadingHandler(false);
  }

  void exportOrders(BuildContext context, Function loadingHandler, List<Order> orders) async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Orders Data ready to be shared'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    loadingHandler(true);
    try {
      List<List<String>> newOrders = [Order.headers];

      orders.forEach((order) {
        newOrders.add(order.toStringList());
      });

      String csvData = ListToCsvConverter().convert(newOrders);
      String directory  = (await getTemporaryDirectory()).path;
      final path = "$directory/QuickStore_Orders_${DateTime.now()}.csv";
      final File file = File(path);
      File csvFile = await file.writeAsString(csvData);

      if(csvFile != null) {
        Share.shareFiles([csvFile.path],
            text: 'QuickStore Orders', subject: 'QuickStore Orders Data');
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch(e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Export Orders'),
            content: Text(e.toString()),
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
    loadingHandler(false);
  }

  void importInventory(BuildContext context, Function loadingHandler, StoreBloc bloc) async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Inventory imported'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    loadingHandler(true);
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    try {
      if (result != null) {
        PlatformFile file = result.files.first;

        Uint8List bytes = await (new File(file.path)).readAsBytes();
        DecodingResult decodingResult = await CharsetDetector.autoDecode(bytes);

        var rows =  const CsvToListConverter(allowInvalid: false).convert(decodingResult.string);

        rows.removeAt(0);
        List<Product> products = rows.map((row) => Product.fromList(row)).toList();

        if(products.isNotEmpty) {
          String result = await bloc.importProducts(products);
          if(result == 'SUCCESS') {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            throw 'Failed to add products to the database';
          }
        } else {
          throw 'CSV file is empty';
        }
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Import Inventory'),
            content: Text(e.toString()),
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
    loadingHandler(false);
  }

  void importOrders(BuildContext context, Function loadingHandler, StoreBloc bloc) async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Orders imported'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    loadingHandler(true);
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    try {
      if (result != null) {
        PlatformFile file = result.files.first;

        Uint8List bytes = await (new File(file.path)).readAsBytes();
        DecodingResult decodingResult = await CharsetDetector.autoDecode(bytes);

        var rows =  const CsvToListConverter(allowInvalid: false).convert(decodingResult.string);

        rows.removeAt(0);
        List<Order> orders = rows.map((row) => Order.fromList(row)).toList();

        if(orders.isNotEmpty) {
          String result = await bloc.importOrders(orders);
          if(result == 'SUCCESS') {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            throw 'Failed to add orders to the database';
          }
        } else {
          throw 'CSV file is empty';
        }
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Import Orders'),
            content: Text(e.toString()),
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
    loadingHandler(false);
  }

  void clearInventory(BuildContext context, Function loadingHandler, StoreBloc bloc) async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Inventory cleared'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    loadingHandler(true);
    String result = await bloc.clearProducts();
    if(result == 'SUCCESS') {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Clear Inventory'),
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
    loadingHandler(false);
  }

  void clearOrders(BuildContext context, Function loadingHandler, StoreBloc bloc) async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Orders cleared'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    loadingHandler(true);
    String result = await bloc.clearOrders();
    if(result == 'SUCCESS') {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Clear Orders'),
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
    loadingHandler(false);
  }

  void mergeOrders(BuildContext context, Function loadingHandler, StoreBloc bloc) async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Orders merged and inventory updated'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    loadingHandler(true);
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    try {
      if (result != null) {
        PlatformFile file = result.files.first;

        Uint8List bytes = await (new File(file.path)).readAsBytes();
        DecodingResult decodingResult = await CharsetDetector.autoDecode(bytes);

        var rows =  const CsvToListConverter(allowInvalid: false).convert(decodingResult.string);

        rows.removeAt(0);
        List<Order> orders = rows.map((row) => Order.fromList(row)).toList();

        if(orders.isNotEmpty) {
          String result = await bloc.mergeOrders(orders);
          if(result == 'SUCCESS') {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            throw 'Failed to merge orders to the database';
          }
        } else {
          throw 'CSV file is empty';
        }
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Merge Orders'),
            content: Text(e.toString()),
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
    loadingHandler(false);
  }
}