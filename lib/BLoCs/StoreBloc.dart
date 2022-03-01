import 'dart:async';

import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/models/Order.dart';
import 'package:quick_store/models/Product.dart';
import 'package:quick_store/services/LocalDatabaseService.dart';

class StoreBloc {
  StoreBloc() {
    getStore();
  }

  final _storeController = StreamController<LocalDBDataPack>.broadcast();

  get store => _storeController.stream;

  getStore() async {
    _storeController.sink.add(await LocalDatabaseService.db.getStore());
  }

  Future<Product> getProduct(String pid) async {
    return await LocalDatabaseService.db.getProduct(pid);
  }

  Future<Order> getOrder(String oid) async {
    return await LocalDatabaseService.db.getOrder(oid);
  }

  Future<String> addProduct(Product product) async {
    String result = '';
    result = await LocalDatabaseService.db.addProduct(product);
    getStore();
    return result;
  }

  Future<String> addOrder(Order order) async {
    String result = '';
    result = await LocalDatabaseService.db.addOrder(order);
    getStore();
    return result;
  }

  Future<String> editProduct(Product product) async {
    String result = '';
    result = await LocalDatabaseService.db.editProduct(product);
    getStore();
    return result;
  }

  Future<String> editOrder(Order order) async {
    String result = '';
    result = await LocalDatabaseService.db.editOrder(order);
    getStore();
    return result;
  }

  Future<String> deleteProduct(String pid) async {
    String result = '';
    result = await LocalDatabaseService.db.deleteProduct(pid);
    getStore();
    return result;
  }

  Future<String> deleteOrder(String oid) async {
    String result = '';
    result = await LocalDatabaseService.db.deleteOrder(oid);
    getStore();
    return result;
  }

  Future<String> clearProducts() async {
    String result = '';
    result = await LocalDatabaseService.db.clearProducts();
    getStore();
    return result;
  }

  Future<String> clearOrders() async {
    String result = '';
    result = await LocalDatabaseService.db.clearOrders();
    getStore();
    return result;
  }

  Future<String> importOrders(List<Order> orders) async {
    String result = '';
    result = await LocalDatabaseService.db.importOrders(orders);
    getStore();
    return result;
  }

  dispose() {
    _storeController.close();
  }
}