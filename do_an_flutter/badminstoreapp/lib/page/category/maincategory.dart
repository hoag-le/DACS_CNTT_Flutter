import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/categorylist.dart';
import 'categoryproduct.dart';

class MainCategoryPage extends ConsumerStatefulWidget {
  final int initialCategoryId;

  const MainCategoryPage({Key? key, required this.initialCategoryId})
    : super(key: key);

  @override
  _MainCategoryPageState createState() => _MainCategoryPageState();
}

class _MainCategoryPageState extends ConsumerState<MainCategoryPage> {
  late int _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  void _onCategorySelected(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Danh mục sản phẩm',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CategoryList(onCategorySelected: _onCategorySelected),

            CategoryProductWidget(categoryId: _selectedCategoryId),
          ],
        ),
      ),
    );
  }
}
