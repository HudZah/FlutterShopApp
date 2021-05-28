import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    var tempFavorite = isFavorite;
    isFavorite = !isFavorite;
    final url =
        "https://flutterupdate-aed81-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json";
    notifyListeners();
    final response = await http.patch(Uri.parse(url),
        body: json.encode({"isFavorite": isFavorite}));
    if (response.statusCode >= 400) {
      isFavorite = tempFavorite;
      notifyListeners();
      throw new HttpException("Could not set product as favorite");
    }

    tempFavorite = null;
  }
}
