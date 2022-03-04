import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/FieldLabel.dart';
import 'package:quick_store/models/Product.dart';
import 'package:quick_store/services/DataService.dart';
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
    var status = await DataService.ds.writePermissionHandler(context);

    if(status) {
      bool success = await DataService.ds.downloadQRImage(context, product);
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Save QR Code'),
          content: Text('Write Permission Denied'),
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: Color(0xFFF2E7E7),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(onPressed: downloadHandler, icon: Icon(Icons.download_rounded)),
          ] + (widget.isNew ? [] : [
            IconButton(onPressed: deleteHandler, icon: Icon(Icons.delete_forever_rounded)),
          ]),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                QrImage(
                    data: product.pid + '<=QuickStore=>' + product.pid,
                    version: QrVersions.auto,
                    size: 150
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FieldLabel(
                        label: 'Product Name',
                        child: TextFormField(
                          initialValue: product.name,
                          decoration: formFieldDecoration.copyWith(hintText: 'Product Name'),
                          validator: (val) => val.isEmpty ? 'Enter Product Name' : null,
                          onChanged: (val) => setState(() => product.name = val),
                        ),
                      ),
                      FieldLabel(
                        label: 'Price',
                        child: TextFormField(
                          initialValue: product.price.toString(),
                          decoration: formFieldDecoration.copyWith(hintText: 'Product Price'),
                          validator: (val) => val.isEmpty ? 'Enter Product Price' : null,
                          onChanged: (val) => setState(() => product.price = val == '' ? 0 : double.parse(val)),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      FieldLabel(
                        label: 'Quantity',
                        child: TextFormField(
                          initialValue: product.quantity.toString(),
                          decoration: formFieldDecoration.copyWith(hintText: 'Quantity'),
                          validator: (val) => val.isEmpty ? 'Enter Quantity' : null,
                          onChanged: (val) => setState(() => product.quantity = val == '' ? 0 : int.parse(val)),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      FieldLabel(
                        label: 'Expiration',
                        child: DropdownButtonFormField(
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
                      ),
                      FieldLabel(
                        label: 'Total Price',
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.all(16),
                          decoration: labelFieldDecoration,
                          child: Text('₱ ${(product.quantity * product.price).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16)),
                        )
                      ),
                      TextButton(
                        onPressed: submitHandler,
                        child: Text('SAVE'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xFFC4C4C4)),
                            foregroundColor: MaterialStateProperty.all(Colors.black)
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
