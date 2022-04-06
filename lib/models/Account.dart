class Account {
  String uid;
  String username;

  Account({this.uid, this.username});

  Account.fromLocalDB (Map<String, dynamic> fields) {
    Map<String, dynamic> newFields = fields;
    this.uid = newFields['uid'];
    this.username = newFields['username'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'username': this.username,
    };
  }
}