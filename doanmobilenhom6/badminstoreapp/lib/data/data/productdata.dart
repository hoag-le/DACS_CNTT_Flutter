import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/productmodel.dart';
import '../../services/firestore_service.dart';

class ReadData {
  Future<List<ProductModel>> loadData() async {
    try {
      final firestoreProducts = await FirestoreService.getProducts();
      if (firestoreProducts.isNotEmpty) {
        return firestoreProducts;
      }
      return await _loadFromJson();
    } catch (e) {
      return await _loadFromJson();
    }
  }

  Future<List<ProductModel>> _loadFromJson() async {
    try {
      var data = await rootBundle.loadString('assets/files/productlist.json');
      var dataJson = jsonDecode(data);
      return (dataJson['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}