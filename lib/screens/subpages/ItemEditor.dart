import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/Product.dart';
import 'package:quick_store/shared/decorations.dart';
import 'package:uuid/uuid.dart';

class ItemEditor extends StatefulWidget {
  final StoreBloc bloc;
  final bool isNew;
  final Product product;
  const ItemEditor({Key key, this.bloc, this.isNew, this.product}) : super(key: key);

  @override
  _ItemEditorState createState() => _ItemEditorState();
}

class _ItemEditorState extends State<ItemEditor> {
  final _formKey = GlobalKey<FormState>();
  Product product;
  String expiration = '1 Week';
  List<String> expirationChoices = [
    '1 Week',
    '1 Month',
    '1 Year'
  ];

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)
    );
  }

  void submitHandler() async {
    product.expiration = expiration;
    String result = widget.isNew ? await widget.bloc.addProduct(product) : await widget.bloc.editProduct(product);
    if(result == 'SUCCESS') {
      final snackBar = SnackBar(
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: Text('Product ${widget.isNew ? 'added' : 'edited'}'),
        action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${widget.isNew ? 'Adding' : 'Editing'} Product'),
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

  void expireHandler(String value) {
    setState(() {
      expiration = value;
    });
  }

  void deleteHandler() async {
    if(!widget.isNew) {
      String result = '';
      result = await widget.bloc.deleteProduct(product.pid);
      if(result == 'SUCCESS') {
        final snackBar = SnackBar(
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text('Product deleted'),
          action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Delete Product'),
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
  }

  void downloadHandler() async {
    var status = await Permission.storage.status;
    bool success = false;

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

    if(status.isGranted){
      final qrValidationResult = QrValidator.validate(
        data: product.pid + '<=QuickShop=>' + product.pid,
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

      success = await GallerySaver.saveImage(path);
    }

    if(success) {
      final snackBar = SnackBar(
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        content: Text('QR image saved to your Gallery'),
        action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Save QR Code'),
            content: Text('Failed to save QR image to your Gallery'),
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

  @override
  void initState() {
    super.initState();
    if(widget.isNew) {
      var uuid = Uuid();
      product = Product();
      product.pid = uuid.v1();
    } else {
      product = Product(
        pid: widget.product.pid,
        name: widget.product.name,
        price: widget.product.price,
        quantity: widget.product.quantity,
        expiration: widget.product.expiration
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Product ${widget.isNew ? 'Creator' : 'Editor'}'),
        actions: [
          IconButton(onPressed: downloadHandler, icon: Icon(Icons.download_rounded)),
        ] + (widget.isNew ? [] : [
          IconButton(onPressed: deleteHandler, icon: Icon(Icons.delete_forever_rounded)),
        ]),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              QrImage(
                data: product.pid + '<=QuickShop=>' + product.pid,
                version: QrVersions.auto,
                size: 200
              ),
              TextFormField(
                initialValue: product.name,
                decoration: formFieldDecoration.copyWith(hintText: 'Product Name'),
                validator: (val) => val.isEmpty ? 'Enter Product Name' : null,
                onChanged: (val) => setState(() => product.name = val),
              ),
              TextFormField(
                initialValue: product.price.toString(),
                decoration: formFieldDecoration.copyWith(hintText: 'Product Price'),
                validator: (val) => val.isEmpty ? 'Enter Product Price' : null,
                onChanged: (val) => setState(() => product.price = val == '' ? 0 : double.parse(val)),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                initialValue: product.quantity.toString(),
                decoration: formFieldDecoration.copyWith(hintText: 'Quantity'),
                validator: (val) => val.isEmpty ? 'Enter Quantity' : null,
                onChanged: (val) => setState(() => product.quantity = val == '' ? 0 : int.parse(val)),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField(
                menuMaxHeight: 500,
                isExpanded: true,
                value: expiration,
                items: expirationChoices.map((String expire) => DropdownMenuItem(
                    value: expire,
                    child: Text(expire, overflow: TextOverflow.ellipsis)
                )).toList(),
                onChanged: (value) => expireHandler(value),
                decoration: searchFieldDecoration,
              ),
              TextButton(
                onPressed: submitHandler,
                child: Text('SAVE'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(theme.primaryColor),
                  foregroundColor: MaterialStateProperty.all(Colors.white)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
