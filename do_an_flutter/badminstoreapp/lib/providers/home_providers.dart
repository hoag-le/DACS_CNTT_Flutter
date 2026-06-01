import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data/productdata.dart';
import '../data/data/sliderdata.dart';
import '../data/data/categorydata.dart';
import '../data/model/productmodel.dart';
import '../data/model/slidermodel.dart';
import '../data/model/categorymodel.dart';

final sliderProvider = FutureProvider<List<SliderModel>>((ref) async {
  return await SliderData().loadData();
});

final productsProviderData = FutureProvider<List<ProductModel>>((ref) async {
  return await ReadData().loadData();
});

final categoryProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return await CategoryData().loadData();
});
