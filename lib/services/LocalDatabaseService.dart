import 'dart:async';

import 'package:quick_store/models/Account.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/models/LoginResponse.dart';
import 'package:quick_store/models/Order.dart';
import 'package:quick_store/models/OrderItem.dart';
import 'package:quick_store/models/Product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  LocalDatabaseService._();

  static final LocalDatabaseService db = LocalDatabaseService._();

  Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;
    _database = await openDatabase(
        join(await getDatabasesPath(), 'store_database.db'),
        onCreate: (db, version) {
          Batch batch = db.batch();
          batch.execute(
              'CREATE TABLE products(pid TEXT PRIMARY KEY, name TEXT, sellingPrice REAL, quantity INTEGER, expiration TEXT, originalPrice REAL )'
          );
          batch.execute('CREATE TABLE orders(oid TEXT PRIMARY KEY, datetime TEXT, itemString TEXT, username TEXT)');
          batch.execute('CREATE TABLE users(uid TEXT PRIMARY KEY, username TEXT)');
          return batch.commit();
        },
        version: 1
    );
    return _database;
  }

  Future<LocalDBDataPack> getStore() async {
    List<Product> products = await getProducts();
    List<Order> orders = await getOrders();
    bool hasProducts = await getHasProducts();
    bool hasOrders = await getHasOrders();

    return LocalDBDataPack(products: products, orders: orders, hasOrders: hasOrders, hasProducts: hasProducts);
  }

  Future<List<Product>> getProducts() async {
    Database db = await database;
    List<Map<String, Object>> maps;

    maps = await db.query('products');

    return List.generate(maps.length, (i) {
      return Product.fromLocalDB(maps[i]);
    });
  }

  Future<List<Order>> getOrders() async {
    Database db = await database;
    List<Map<String, Object>> maps = await db.query('orders');

    return List.generate(maps.length, (i) {
      return Order.fromLocalDB(maps[i]);
    });
  }

  Future<String> addProduct(Product item) async {
    String result = '';
    Database db = await database;

    await db.insert(
      'products',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )
      .then((value) => result = 'SUCCESS')
      .catchError((error) => result = error.toString());
    return result;
  }

  Future<String> addOrder(Order order, Map<String, int> newQuantity) async {
    String result = '';
    Database db = await database;
    Batch batch = db.batch();

    newQuantity.forEach((key, value) {
      batch.rawUpdate('UPDATE products SET quantity = ? WHERE pid = ?', [value, key]);
    });

    batch.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await batch.commit().then((value) => result = 'SUCCESS')
      .catchError((error) => result = error.toString());
    return result;
  }

  Future<String> editProduct(Product item) async {
    String result = '';
    Database db = await database;
    await db.update(
      'products',
      item.toMap(),
      where: 'pid = ?',
      whereArgs: [item.pid],
    )
        .then((value) => result = 'SUCCESS')
        .catchError((error) => result = error.toString());
    return result;
  }

  Future<String> editOrder(Order order) async {
    String result = '';
    Database db = await database;
    await db.update(
      'orders',
      order.toMap(),
      where: 'oid = ?',
      whereArgs: [order.oid],
    )
        .then((value) => result = 'SUCCESS')
        .catchError((error) => result = error.toString());
    return result;
  }

  Future<String> deleteProduct(String pid) async {
    String result = '';
    Database db = await database;
    await db.delete(
      'products',
      where: 'pid = ?',
      whereArgs: [pid],
    )
        .then((value) => result = 'SUCCESS')
        .catchError((error) => result = error.toString());
    return result;
  }

  Future<String> deleteOrder(String oid) async {
    String result = '';
    Database db = await database;
    await db.delete(
      'order',
      where: 'oid = ?',
      whereArgs: [oid],
    )
        .then((value) => result = 'SUCCESS')
        .catchError((error) => result = error.toString());
    return result;
  }

  Future<Product> getProduct(String pid) async {
    Database db = await database;
    List<Map<String, Object>> maps = await db.query(
        'products',
        where: 'pid = ?',
        whereArgs: [pid],
        limit: 1
    );

    if(maps == null || maps.isEmpty)
      return null;

    return Product.fromLocalDB(maps[0]);
  }

  Future<Product> getProductByName(String name) async {
    Database db = await database;
    List<Map<String, Object>> maps = await db.query(
        'products',
        where: 'name = ?',
        whereArgs: [name],
        limit: 1
    );

    if(maps == null || maps.isEmpty)
      return null;

    return Product.fromLocalDB(maps[0]);
  }

  Future<Order> getOrder(String oid) async {
    Database db = await database;
    List<Map<String, Object>> maps = await db.query(
        'orders',
        where: 'oid = ?',
        whereArgs: [oid],
        limit: 1
    );

    if(maps == null || maps.isEmpty)
      return null;

    return Order.fromLocalDB(maps[0]);
  }

  Future<bool> getHasProducts() async {
    Database db = await database;
    int count = Sqflite
        .firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    return count != 0;
  }

  Future<bool> getHasOrders() async {
    Database db = await database;
    int count = Sqflite
        .firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM orders'));
    return count != 0;
  }

  Future<LoginResponse> login(String username) async {
    Database db = await database;
    List<Map<String, Object>> maps = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
        limit: 1
    );

    if(maps == null || maps.isEmpty)
      return LoginResponse(null, 'Incorrect Username');

    return LoginResponse(Account.fromLocalDB(maps[0]), 'SUCCESS');
  }

  Future<String> signup(Account account) async {
    String result = '';
    Database db = await database;

    List<Map<String, Object>> maps = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [account.username],
        limit: 1
    );

    if(maps == null || maps.isEmpty) {
      await db.insert(
        'users',
        account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
          .then((value) => result = 'SUCCESS')
          .catchError((error) => result = error.toString());
      return result;
    } else {
      return 'Username already exist';
    }
  }

  Future<String> importProducts(List<Product> products) async {
    Database db = await database;
    String result = '';
    Batch batch = db.batch();

    batch.execute("DROP TABLE IF EXISTS products");
    batch.execute(
        'CREATE TABLE products(pid TEXT PRIMARY KEY, name TEXT, sellingPrice REAL, quantity INTEGER, expiration TEXT, originalPrice REAL )'
    );

    products.forEach((product) => batch.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace)
    );
    await batch.commit()
        .then((value) => result = 'SUCCESS')
        .catchError((error) => result = error.toString());

    return result;
  }

  Future<String> importOrders(List<Order> orders) async {
    Database db = await database;
    String result = '';
    Batch batch = db.batch();

    batch.execute("DROP TABLE IF EXISTS orders");
    batch.execute('CREATE TABLE orders(oid TEXT PRIMARY KEY, datetime TEXT, itemString TEXT, username TEXT)');
    orders.forEach((order) => batch.insert(
        'orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace)
    );
    await batch.commit()
        .then((value) => result = 'SUCCESS')
        .catchError((error) => result = error.toString());

    return result;
  }

  Future<String> mergeOrders(List<Order> orders) async {
    String result = '';

    await Future.wait(orders.map((order) async {
      Order existingOrder = await getOrder(order.oid);

      try {
        if(existingOrder == null) {
          Map<String, int> newQuantity = {};
          List<String> orderItemStrings = order.itemString.split(';').toList();
          print(orderItemStrings);

          await Future.forEach(orderItemStrings, (itemString) async {
            OrderItem orderItem = OrderItem.fromString(itemString);
            Product product = await getProduct(orderItem.pid);

            newQuantity[orderItem.pid] = product.quantity - orderItem.quantity;
          });

          print(newQuantity);

          await addOrder(order, newQuantity);
        }
        return true;
      } catch(e) {
        print(e);
        return false;
      }

    })).then((value) {
      print(value);
      bool output = value.reduce((value, element) => value && element);
      if(output) {
        result = 'SUCCESS';
      } else {
        result = 'Orders failed to merge';
      }
    }).catchError((err) => result = err.toString());

    return result;
  }

  Future<String> clearProducts() async {
    String result = '';
    Database db = await database;
    Batch batch = db.batch();

    batch.execute("DROP TABLE IF EXISTS products");
    batch.execute(
        'CREATE TABLE products(pid TEXT PRIMARY KEY, name TEXT, sellingPrice REAL, quantity INTEGER, expiration TEXT, originalPrice REAL )'
    );

    await batch.commit()
        .then((value) => result = 'SUCCESS')
        .catchError((error) => result = error.toString());

    return result;
  }

  Future<String> clearOrders() async {
    String result = '';
    Database db = await database;
    Batch batch = db.batch();

    batch.execute("DROP TABLE IF EXISTS orders");
    batch.execute('CREATE TABLE orders(oid TEXT PRIMARY KEY, datetime TEXT, itemString TEXT, username TEXT)');

    await batch.commit()
        .then((value) => result = 'SUCCESS')
        .catchError((error) => result = error.toString());

    return result;
  }
}