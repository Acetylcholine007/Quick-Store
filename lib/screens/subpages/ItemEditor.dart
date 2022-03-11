import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/FieldLabel.dart';
import 'package:quick_store/models/Product.dart';
import 'package:quick_store/services/DataService.dart';
import 'package:quick_store/services/NotificationService.dart';
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
  DateTime expiration = DateTime.now();
  bool withExpiration = false;

  DateTime getDateTime(String datetime) {
    List<int> values = datetime.split('-').map((value) => int.parse(value)).toList();
    return DateTime(values[0], values[1], values[2]);
  }

  void submitHandler() async {
    if (_formKey.currentState.validate()) {
      product.expiration = withExpiration ? expiration.toString().split(' ')[0] : 'None';
      String result = widget.isNew
          ? await widget.bloc.addProduct(product)
          : await widget.bloc.editProduct(product);
      if (result == 'SUCCESS') {
        final snackBar = SnackBar(
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          content: Text('Product ${widget.isNew ? 'added' : 'edited'}'),
          action: SnackBarAction(label: 'OK',
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar()),
        );

        if(product.expiration != 'None') {
          NotificationService.showScheduledNotification(
            id: product.pid.hashCode,
            title: 'QuickStore Expiration Notice',
            body: '${product.name} will reach expiration date in three days.',
            payload: product.pid,
            scheduleDate: getDateTime(product.expiration).subtract(Duration(days: 3))
          );
          NotificationService.showScheduledNotification(
            id: product.pid.hashCode + 1,
            title: 'QuickStore Expiration Notice',
            body: '${product.name} reached expiration date.',
            payload: product.pid,
            scheduleDate: getDateTime(product.expiration)
          );
        } else {
          NotificationService.cancel(product.pid.hashCode);
          NotificationService.cancel(product.pid.hashCode + 1);
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
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
    } else {
      final snackBar = SnackBar(
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: Text('Fill up all the fields correctly'),
        action: SnackBarAction(label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context)
                    .hideCurrentSnackBar()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
          snackBar);
    }
  }

  void expireHandler(DateTime value) {
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
        if(product.expiration != 'None') {
          NotificationService.cancel(product.pid.hashCode);
          NotificationService.cancel(product.pid.hashCode + 1);
        }

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
      product = widget.product;
      expiration = widget.product.expiration == 'None' ? DateTime.now() : getDateTime(widget.product.expiration);
      withExpiration = widget.product.expiration == 'None' ? false : true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print(product.originalPrice);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: theme.primaryColorLight,
        appBar: AppBar(
          title: Text(widget.isNew ? 'Create Product' : 'Edit Product'),
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
                          validator: (val) => val.isEmpty ? 'Enter Product Name' : RegExp(r'[.,%]').hasMatch(val) ? "Name should not contain '%,;'": null,
                          onChanged: (val) => setState(() => product.name = val),
                        ),
                      ),
                      FieldLabel(
                        label: 'Original Price',
                        child: TextFormField(
                          initialValue: product.originalPrice.toString(),
                          decoration: formFieldDecoration.copyWith(hintText: 'Original Price'),
                          validator: (val) => val.isEmpty ? 'Enter Original Price' : null,
                          onChanged: (val) => setState(() => product.originalPrice = val == '' ? 0 : double.parse(val)),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      FieldLabel(
                        label: 'Selling Price',
                        child: TextFormField(
                          initialValue: product.sellingPrice.toString(),
                          decoration: formFieldDecoration.copyWith(hintText: 'Selling Price'),
                          validator: (val) => val.isEmpty ? 'Enter Selling Price' : double.parse(val) <= product.originalPrice ? "Selling price should be greater than the original price" : null,
                          onChanged: (val) => setState(() => product.sellingPrice = val == '' ? 0 : double.parse(val)),
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
                        sunken: false,
                        label: 'Expiration',
                        child: Row(
                          children: [
                            Switch(value: withExpiration, onChanged: (val) {
                              setState(() => withExpiration = val);
                            }),
                            Expanded(
                              child: ElevatedButton(
                                  style: formButtonDecoration,
                                  onPressed: () => withExpiration ? showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(Duration(days: 7)),
                                  lastDate: DateTime(DateTime.now().year + 5),
                              ).then((pickedDate) {
                                if (pickedDate == null) {
                                  return;
                                }
                                setState(() {
                                  expiration = pickedDate;
                                });
                              }) : null, child: Text(withExpiration ? '${DateFormat('MMMM dd, yyyy').format(expiration)}' : 'No Expiration')
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FieldLabel(
                              label: 'Revenue',
                              child: Container(
                                height: 50,
                                padding: EdgeInsets.all(16),
                                decoration: labelFieldDecoration.copyWith(color: theme.backgroundColor),
                                child: Text('₱ ${(product.quantity * product.sellingPrice).toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16)),
                              )
                            ),
                          ),
                          SizedBox(width: 16,),
                          Expanded(
                            child: FieldLabel(
                                label: 'Profit',
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.all(16),
                                  decoration: labelFieldDecoration.copyWith(color: theme.backgroundColor),
                                  child: Text('₱ ${(product.quantity * (product.sellingPrice - product.originalPrice)).toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 16)),
                                )
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: submitHandler,
                        child: Text('SAVE'),
                        style: formButtonDecoration,
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
