import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_providers.dart';
import '../../data/model/productmodel.dart';
import '../product/productbody.dart';
import '../../widgets/app_state_widgets.dart';
class SearchResultPage extends ConsumerStatefulWidget {
  final String searchQuery;

  const SearchResultPage({Key? key, required this.searchQuery})
    : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  late TextEditingController _searchController;
  late String _currentQuery;

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery;
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      _currentQuery = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProviderData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFDF1E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: _onSearchSubmitted,
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm tên sản phẩm và nhãn hiệu',
              hintStyle: TextStyle(color: Colors.orange),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: Icon(Icons.search, color: Colors.black),
            ),
          ),
        ),
      ),
      body: productsAsyncValue.when(
        data: (allProducts) {
          if (_currentQuery.isEmpty) {
            return const AppEmptyWidget(
              message: 'Vui lòng nhập từ khóa tìm kiếm',
              icon: Icons.search,
            );
          }

          List<ProductModel> searchResults =
              allProducts
                  .where(
                    (product) =>
                        product.productName != null &&
                        product.productName!.toLowerCase().contains(
                          _currentQuery.toLowerCase(),
                        ),
                  )
                  .toList();

          if (searchResults.isEmpty) {
            return const AppEmptyWidget(
              message: 'Không tìm thấy sản phẩm phù hợp',
              icon: Icons.search_off,
            );
          }

          return SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: Text(
                      'Kết quả tìm kiếm (${searchResults.length} sản phẩm)',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return itemGridView(searchResults[index], ref);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (e, s) => const AppErrorWidget(),
      ),
    );
  }
}
