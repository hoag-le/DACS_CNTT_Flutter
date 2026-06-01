import 'package:flutter/material.dart';
import '../home/mainhome.dart';
import '../search/search.dart';
import '../cart/productcart.dart';
import '../../data/model/usermodel.dart';

class HomeWidget extends StatelessWidget {
  final UserModel? user;

  const HomeWidget({Key? key, required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
        ),
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmptyCartPage(user: user),
                ),
              );
            },
          ),
        ],
      ),
      body: MainHome(),
    );
  }
}
