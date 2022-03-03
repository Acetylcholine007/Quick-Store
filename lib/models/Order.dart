class Order {
  String oid;
  String datetime;
  String itemString;

  Order({this.oid, this.datetime, this.itemString});

  Order.fromLocalDB (Map<String, dynamic> fields) {
    Map<String, dynamic> newFields = fields;
    this.oid = newFields['oid'];
    this.datetime = newFields['datetime'];
    this.itemString = newFields['itemString'];
  }

  Map<String, dynamic> toMap() {
    return {'oid': this.oid, 'datetime': this.datetime, 'itemString': this.itemString};
  }
}