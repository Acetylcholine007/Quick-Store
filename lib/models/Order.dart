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

  Order.fromList(List row) {
    this.oid = row[0].toString();
    this.datetime = row[1].toString();
    this.itemString = row[2].toString();
  }

  Map<String, dynamic> toMap() {
    return {'oid': this.oid, 'datetime': this.datetime, 'itemString': this.itemString};
  }

  List<String> toStringList() {
    return [this.oid, this.datetime, this.itemString];
  }

  static List<String> get headers => ['oid', 'datetime', 'itemString'];
}