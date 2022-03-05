class Account {
  String uid;
  String contact;
  String username;
  String password;

  Account({this.uid, this.contact, this.username, this.password});

  Account.fromLocalDB (Map<String, dynamic> fields) {
    Map<String, dynamic> newFields = fields;
    this.uid = newFields['uid'];
    this.contact = newFields['contact'];
    this.username = newFields['username'];
    this.password = newFields['password'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'contact': this.contact,
      'username': this.username,
      'password': this.password
    };
  }
}