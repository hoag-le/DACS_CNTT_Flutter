import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/home_providers.dart';
import '../../data/model/slidermodel.dart';
import '../../conf/const.dart';
import '../../widgets/app_state_widgets.dart';

class SliderWidget extends ConsumerStatefulWidget {
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends ConsumerState<SliderWidget> {
  PageController _pageController = PageController();
  Timer? _timer;
  int currentPage = 0;
  bool _timerStarted = false;

  void startAutoScroll(int length) {
    if (length == 0 || _timerStarted) return;
    _timerStarted = true;

    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        setState(() {
          currentPage = (currentPage + 1) % length;
        });

        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildSliderItem(SliderModel slider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          '$uri_slider_img${slider.image}',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 60, color: Colors.grey[600]),
            );
          },
        ),
      ),
    );
  }

  Widget buildPageIndicator(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => Container(
          width: currentPage == index ? 12 : 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: currentPage == index ? Colors.brown[600] : Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sliderAsyncValue = ref.watch(sliderProvider);

    return sliderAsyncValue.when(
      data: (sliders) {
        if (sliders.isEmpty) {
          return const AppEmptyWidget(
            message: 'Không có banner nào',
            icon: Icons.image_outlined,
            height: 200,
          );
        }

        startAutoScroll(sliders.length);

        return Container(
          margin: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: sliders.length,
                  itemBuilder: (context, index) {
                    return buildSliderItem(sliders[index]);
                  },
                ),
              ),
              SizedBox(height: 16),
              buildPageIndicator(sliders.length),
            ],
          ),
        );
      },
      loading: () => const AppLoadingWidget(height: 200),
      error: (error, stack) => const AppErrorWidget(height: 200),
    );
  }
}
