class Order {
  String oid;
  String datetime;
  String itemString;
  String username;

  Order({this.oid, this.datetime, this.itemString, this.username});

  Order.fromLocalDB (Map<String, dynamic> fields) {
    Map<String, dynamic> newFields = fields;
    this.oid = newFields['oid'];
    this.datetime = newFields['datetime'];
    this.itemString = newFields['itemString'];
    this.username = newFields['username'];
  }

  Order.fromList(List row) {
    this.oid = row[0].toString();
    this.datetime = row[1].toString();
    this.itemString = row[2].toString();
    this.username = row[3].toString();
  }

  Map<String, dynamic> toMap() {
    return {'oid': this.oid, 'datetime': this.datetime, 'itemString': this.itemString, 'username': this.username};
  }

  List<String> toStringList() {
    return [this.oid, this.datetime, this.itemString, this.username];
  }

  static List<String> get headers => ['oid', 'datetime', 'itemString', 'username'];
}