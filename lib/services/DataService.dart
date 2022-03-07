import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/Order.dart';
import 'package:quick_store/models/OrderItem.dart';
import 'package:quick_store/models/Product.dart';
import 'package:quick_store/models/ProductData.dart';
import 'package:share/share.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  Future<List<File>> downloadQRCodes(List<Product> products) async {
    List<File> imageFiles = [];
    await Future.forEach(products, (product) async {
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

      final picData = await painter.toImageData(256,
          format: ui.ImageByteFormat.png);
      await writeToFile(picData, path);

      imageFiles.add(File(path));
    });

    return imageFiles;
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

    final picData = await painter.toImageData(256,
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

        rows.forEach((element) => print(element));
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

  void printOrderToPDF(BuildContext context, Function loadingHandler, List<Order> orders) async {
    final pdf = pw.Document();

    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('PDF report generated'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );
    final snackBar2 = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Saving cancelled'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    void printPDFPage(DateTime indexDay, Map<String, ProductData> products, {bool isMonth = false}) {
      pdf.addPage(
          pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Container(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Column(
                        children: [
                          isMonth ? pw.Text('Tally for the month of ${DateFormat('MMMM').format(indexDay)}', style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold
                          )) : pw.Text('${DateFormat('MMMM dd, yyyy').format(indexDay)} Tally', style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold
                              )),
                          pw.SizedBox(height: 20),
                          pw.Row(
                            children: [
                              pw.Expanded(
                                flex: 3,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(2),
                                  child: pw.Text('Product', textAlign: pw.TextAlign.center, overflow: pw.TextOverflow.clip),
                                ),
                              ),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(2),
                                  child: pw.Text('Qty', textAlign: pw.TextAlign.center, overflow: pw.TextOverflow.clip),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(2),
                                  child: pw.Text('Selling Price', textAlign: pw.TextAlign.center, overflow: pw.TextOverflow.clip),
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.all(2),
                                  child: pw.Text('Profit', textAlign: pw.TextAlign.center, overflow: pw.TextOverflow.clip),
                                ),
                              ),
                            ],
                          ),
                          pw.Expanded(
                            flex: 1,
                              child: products.isNotEmpty ? pw.Table(
                                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                                columnWidths: const <int, pw.TableColumnWidth>{
                                  0: pw.IntrinsicColumnWidth(flex: 3),
                                  1: pw.IntrinsicColumnWidth(flex: 1),
                                  2: pw.IntrinsicColumnWidth(flex: 2),
                                  3: pw.IntrinsicColumnWidth(flex: 2),
                                },
                                children: products.entries.map((product) => pw.TableRow(
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColors.white,
                                    ),
                                    children: [
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                        child: pw.Text(product.key, textAlign: pw.TextAlign.left, overflow: pw.TextOverflow.clip),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                        child: pw.Text(product.value.quantity.toString(), textAlign: pw.TextAlign.left, overflow: pw.TextOverflow.clip),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                        child: pw.Text(product.value.totalSellingPrice.toStringAsFixed(2), textAlign: pw.TextAlign.left, overflow: pw.TextOverflow.clip),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                        child: pw.Text(product.value.totalProfit.toStringAsFixed(2), textAlign: pw.TextAlign.left, overflow: pw.TextOverflow.clip),
                                      ),
                                    ]
                                )).toList(),
                              ) : pw.Center(child: pw.Text('No Orders at the month of \n${DateFormat('MMMM').format(indexDay)}', textAlign: pw.TextAlign.center))
                          ),
                          pw.Divider(thickness: 1, height: 20, color: PdfColors.grey),
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              pw.Expanded(
                                  flex: 1,
                                  child: pw.Center(child: pw.Text('${DateFormat('MM/dd/yy').format(indexDay)}\nSummary'))
                              ),
                              pw.Expanded(
                                flex:2,
                                child: pw.Table(
                                  defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                                  border: pw.TableBorder(horizontalInside: pw.BorderSide(width: 1)),
                                  columnWidths: const <int, pw.TableColumnWidth>{
                                    0: pw.IntrinsicColumnWidth(flex: 1),
                                    1: pw.IntrinsicColumnWidth(flex: 2)
                                  },
                                  children: [
                                    pw.TableRow(
                                      children: [
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(2),
                                          child: pw.Text('Revenue', textAlign: pw.TextAlign.left, overflow: pw.TextOverflow.clip),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(2),
                                          child: pw.Text('Php ${
                                              products.isNotEmpty ? products.values.map((i) => i.totalSellingPrice).reduce((value, element) => value + element).toStringAsFixed(2) : 0
                                          }', textAlign: pw.TextAlign.right, overflow: pw.TextOverflow.clip),
                                        ),
                                      ]
                                    ),
                                    pw.TableRow(
                                        children: [
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(2),
                                            child: pw.Text('Capital', textAlign: pw.TextAlign.left, overflow: pw.TextOverflow.clip),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(2),
                                            child: pw.Text('Php ${
                                                products.isNotEmpty ? products.values.map((i) => i.totalOriginalPrice).reduce((value, element) => value + element).toStringAsFixed(2) : 0
                                            }', textAlign: pw.TextAlign.right, overflow: pw.TextOverflow.clip),
                                          ),
                                        ]
                                    ),
                                    pw.TableRow(
                                        children: [
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(2),
                                            child: pw.Text('Net Profit', textAlign: pw.TextAlign.left, overflow: pw.TextOverflow.clip),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(2),
                                            child: pw.Text('Php ${
                                                products.isNotEmpty ? products.values.map((i) => i.totalProfit).reduce((value, element) => value + element).toStringAsFixed(2) : 0
                                            }', textAlign: pw.TextAlign.right, overflow: pw.TextOverflow.clip),
                                          ),
                                        ]
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ]
                    )
                ); // Center
              }
          )
      );
    }

    loadingHandler(true);
    DateTime dateToday = DateTime.now();
    try {
      for (DateTime indexDay = DateTime(dateToday.year,dateToday.month,1);
      indexDay.month == dateToday.month;
      indexDay = indexDay.add(Duration(days:1))) {
        String dateToday = indexDay.toString().split(' ')[0];
        Map<String, ProductData> products = {};

        orders.where((order) => order.datetime.split(' ')[0] == dateToday).forEach((order) {
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

        if(products.isNotEmpty) {
          printPDFPage(indexDay, products);
        }
      }

      Map<String, ProductData> products = {};

      orders.forEach((order) {
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

      printPDFPage(DateTime.now(), products, isMonth: true);

      String directory  = (await getTemporaryDirectory()).path;
      final path = "$directory/${DateFormat('MMMM').format(dateToday)}_Report_${dateToday.toString()}.pdf";
      final File file = File(path);

      File pdfFile = await file.writeAsBytes(await pdf.save());

      if(pdfFile != null) {
        final params = SaveFileDialogParams(sourceFilePath: pdfFile.path);
        final filePath = await FlutterFileDialog.saveFile(params: params);
        if(filePath != null)
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        else {
          ScaffoldMessenger.of(context).showSnackBar(snackBar2);
        }
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('PDF generation'),
              content: Text('PDF not saved'),
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
    } catch(e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Generate Report'),
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

  void printQRCodes(BuildContext context, Function loadingHandler, List<Product> products) async {
    print(products);

    final pdf = pw.Document();

    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('QR codes generated'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );
    final snackBar2 = SnackBar(
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Text('Saving cancelled'),
      action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
    );

    int pageCapacity = 20;
    int columns = 4;

    loadingHandler(true);
    List<Product> subProducts (List<Product> products, int start, int sliceLength) {
      List<Product> newProducts;
      if(start + sliceLength < products.length) {
        newProducts = products.sublist(start, start + sliceLength);
      } else {
        newProducts = products.sublist(start);
      }

      return newProducts;
    }

    List<File> imageFiles = await DataService.ds.downloadQRCodes(products);

    print((products.length / pageCapacity).floor() + 1);
    for(int page = 0; page < (products.length / pageCapacity).floor() + 1; page++) {
      print('Page: $page');
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: pw.EdgeInsets.all(4),
              child: pw.GridView(
                crossAxisCount: columns,
                children: subProducts(products, page * pageCapacity, pageCapacity).asMap().entries.map((productEntry) => pw.Column(
                  children: [
                    pw.Image(
                      pw.MemoryImage(
                        imageFiles[page * pageCapacity + productEntry.key].readAsBytesSync(),
                      ),
                      width: 80,
                      height: 80,
                    ),
                    pw.Text(productEntry.value.name, style: pw.TextStyle(fontSize: 12))
                  ]
                )).toList()
              )
            );
          }
        )
      );
    }

    String directory  = (await getTemporaryDirectory()).path;
    final path = "$directory/QuickStore_QR_Codes_${DateTime.now().toString()}.pdf";
    final File file = File(path);

    File pdfFile = await file.writeAsBytes(await pdf.save());

    if(pdfFile != null) {
      final params = SaveFileDialogParams(sourceFilePath: pdfFile.path);
      final filePath = await FlutterFileDialog.saveFile(params: params);
      if(filePath != null)
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      else {
        ScaffoldMessenger.of(context).showSnackBar(snackBar2);
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('QR Code Printing'),
            content: Text('QR codes not saved'),
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