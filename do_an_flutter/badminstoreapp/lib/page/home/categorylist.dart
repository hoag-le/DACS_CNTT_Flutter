import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/home_providers.dart';
import '../../data/model/categorymodel.dart';
import 'package:go_router/go_router.dart';
import '../../conf/const.dart';
import '../../widgets/app_state_widgets.dart';

class CategoryList extends ConsumerStatefulWidget {
  final Function(int)? onCategorySelected;

  const CategoryList({super.key, this.onCategorySelected});

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> {
  final PageController _pageController = PageController();
  Timer? _timer;
  bool _timerStarted = false;

  void startAutoScroll(int length) {
    if (length <= 4 || _timerStarted) return;
    _timerStarted = true;

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        int maxPages = (length / 4).ceil();

        if (nextPage >= maxPages) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildCategoryItem(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        if (widget.onCategorySelected != null) {
          widget.onCategorySelected!(category.id!);
        } else {
          context.push('/category/${category.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5C0),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  '$uri_category_img${category.image}',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.category,
                      size: 30,
                      color: Colors.brown,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.categoryName ?? '',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.brown[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryPage(List<CategoryModel> pageCategories) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          pageCategories
              .map((category) => Expanded(child: buildCategoryItem(category)))
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const AppEmptyWidget(
            message: 'Không có danh mục nào',
            icon: Icons.category_outlined,
            height: 120,
          );
        }

        startAutoScroll(categories.length);

        List<List<CategoryModel>> pages = [];
        for (int i = 0; i < categories.length; i += 4) {
          pages.add(
            categories.sublist(
              i,
              i + 4 > categories.length ? categories.length : i + 4,
            ),
          );
        }

        return Container(
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return buildCategoryPage(pages[index]);
            },
          ),
        );
      },
      loading: () => const AppLoadingWidget(height: 120),
      error: (e, s) => const AppErrorWidget(height: 120),
    );
  }
}
