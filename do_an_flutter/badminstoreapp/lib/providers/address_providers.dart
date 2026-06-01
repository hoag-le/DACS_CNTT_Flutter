import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data/tinhthanhdata.dart';
import '../data/data/phuongxadata.dart';
import '../data/model/provincemodel.dart';
import '../data/model/wardmodel.dart';

final provincesProvider = FutureProvider<List<ProvinceModel>>((ref) async {
  return await TinhThanhData().loadData();
});

final allWardsProvider = FutureProvider<List<WardModel>>((ref) async {
  return await PhuongXaData().loadData();
});

final wardsByProvinceProvider = FutureProvider.family<List<WardModel>, int>((
  ref,
  provinceId,
) async {
  final allWards = await ref.watch(allWardsProvider.future);
  return allWards.where((w) => w.idTinhThanh == provinceId).toList();
});
