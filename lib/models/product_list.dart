import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exception/http_exception.dart';
import 'package:shop/models/product.dart';

import '../utils/constants.dart';

class ProductList with ChangeNotifier {
  final String _userId;
  String _token = "";
  List<Product> _items = []; //dummyProducts;
  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList();

  ProductList(this._token, this._userId, this._items);

  int itemsCount() {
    return _items.length;
  }

  Future<void> loadProducts() async {
    _items.clear();

    final response = await http
        .get(Uri.parse("${Constants.PRODUCT_BASE_URL}.json?auth=$_token"));
    if (response.body == "null") return;

    final favoriteResponse = await http.get(
        Uri.parse("${Constants.USER_FAVORITE_URL}$_userId.json?auth=$_token"));

    Map<String, dynamic> favoriteData = favoriteResponse.body == "null"
        ? {}
        : jsonDecode(favoriteResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      final isFavorite = favoriteData[productId] ?? false;
      _items.add(Product(
        id: productId,
        name: productData["name"],
        description: productData["description"],
        price: productData["price"],
        imageUrl: productData["imageUrl"],
        isFavorite: isFavorite,
      ));
    });
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) async {
    final hasId = data["id"] != null;

    final product = Product(
        id: hasId ? data["id"] as String : Random().nextDouble().toString(),
        name: data["name"] as String,
        description: data["description"] as String,
        price: data["price"] as double,
        imageUrl: data["urlImage"] as String);

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
        Uri.parse("${Constants.PRODUCT_BASE_URL}.json?auth=$_token"),
        body: jsonEncode({
          "name": product.name,
          "price": product.price,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite
        }));

    final id = jsonDecode(response.body)["name"];
    _items.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      isFavorite: product.isFavorite,
    ));
    notifyListeners();
  }

  // Assíncrono sem utilizar o async/await
  // Future<void> addProduct(Product product) {
  //   final future = http.post(Uri.parse("$_baseUrl/products.json"),
  //       body: jsonEncode({
  //         "name": product.name,
  //         "price": product.price,
  //         "description": product.description,
  //         "imageUrl": product.imageUrl,
  //         "isFavorite": product.isFavorite
  //       }));

  //   return future.then((response) {
  //     final id = jsonDecode(response.body)["name"];

  //     _items.add(Product(
  //       id: id,
  //       name: product.name,
  //       description: product.description,
  //       price: product.price,
  //       imageUrl: product.imageUrl,
  //       isFavorite: product.isFavorite,
  //     ));
  //     notifyListeners();
  //   });
  // }

  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      await http.patch(
          Uri.parse(
              "$Constants.PRODUCT_BASE_URL${product.id}.json?auth=$_token"),
          body: jsonEncode({
            "name": product.name,
            "price": product.price,
            "description": product.description,
            "imageUrl": product.imageUrl,
          }));
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    final index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      //_items.removeWhere((element) => element.id == product.id);
      final prod = _items[index];
      _items.remove(prod);
      notifyListeners();

      final response = await http.delete(
          Uri.parse("$Constants.PRODUCT_BASE_URL${prod.id}.json?auth=$_token"));

      if (response.statusCode >= 400) {
        _items.insert(index, prod);
        notifyListeners();
        throw HttpException(
            msg: "Não foi possível excluir o produto.",
            statusCode: response.statusCode);
      }
    }
  }
}

// bool _showFavoriteOnly = false;

//   List<Product> get items {
//     if (_showFavoriteOnly) {
//       return _items.where((product) => product.isFavorite).toList();
//     }
//     return [..._items];
//   }

//   void showFavoriteOnly() {
//     _showFavoriteOnly = true;
//     notifyListeners();
//   }

//   void showAll() {
//     _showFavoriteOnly = false;
//     notifyListeners();
//   }