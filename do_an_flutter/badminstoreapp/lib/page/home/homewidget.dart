import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../home/mainhome.dart';
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
            context.push('/search');
          },
        ),
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              context.push('/cart');
            },
          ),
        ],
      ),
      body: MainHome(),
    );
  }
}
