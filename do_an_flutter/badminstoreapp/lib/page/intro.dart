import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _introData = [
    {
      "image": "assets/images/intro/intro1.jpg",
      "title": "Đặt hàng Online",
      "desc":
          "Bạn đặt hàng trên ứng dụng mua sắm BADMINSTORE thật dễ dàng và nhanh chóng.",
    },
    {
      "image": "assets/images/intro/intro2.jpg",
      "title": "Thanh toán dễ dàng",
      "desc": "Thanh toán an toàn, tiện lợi và bảo mật.",
    },
    {
      "image": "assets/images/intro/intro3.jpg",
      "title": "Giao hàng tận nhà",
      "desc": "Giao hàng nhanh chóng, đưa tận tay sản phẩm đến khách hàng.",
    },
  ];

  void _nextPage() {
    if (_currentIndex < _introData.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _skipIntro() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: _introData.length,
              itemBuilder: (_, index) {
                final data = _introData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(data["image"]!, height: 250),
                      const SizedBox(height: 40),
                      Text(
                        data["title"]!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data["desc"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),

            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _introData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentIndex == index ? Colors.orange : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 24,
              child: ElevatedButton(
                onPressed: _skipIntro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Bỏ qua",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 24,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _currentIndex == _introData.length - 1
                      ? "Bắt đầu"
                      : "Tiếp tục",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
