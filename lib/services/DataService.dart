import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_store/models/Product.dart';
import 'package:uuid/uuid.dart';

class DataService {
  DataService._();

  static final DataService ds = DataService._();

  cameraPermissionHandler () {

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
}