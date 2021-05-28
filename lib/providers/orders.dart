import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url =
        "https://flutterupdate-aed81-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final response = await http.get(Uri.parse(url));
    print(json.decode(response.body));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData["amount"],
          products: (orderData["products"] as List<dynamic>)
              .map((item) => CartItem(
                  id: item["id"],
                  title: item["title"],
                  quantity: item["quantity"],
                  price: item["price"]))
              .toList(),
          dateTime: DateTime.parse(orderData["dateTime"])));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        "https://flutterupdate-aed81-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final timestamp = DateTime.now();
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "amount": total,
          "dateTime": timestamp.toIso8601String(),
          "products": cartProducts
              .map((cp) => {
                    "id": cp.id,
                    "title": cp.title,
                    "quantity": cp.quantity,
                    "price": cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)["id"],
            amount: total,
            dateTime: timestamp,
            products: cartProducts));
    notifyListeners();
  }
}
