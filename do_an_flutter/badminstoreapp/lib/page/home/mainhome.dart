import 'package:flutter/material.dart';
import '../home/bestseller.dart';
import '../home/categorylist.dart';
import '../home/newproduct.dart';
import '../home/recommendedproduct.dart';
import '../home/slider.dart';

class MainHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CategoryList(),
            SliderWidget(),
            BestSellerWidget(),
            NewProductWidget(),
            RecommendedProductWidget(),
          ],
        ),
      ),
    );
  }
}
