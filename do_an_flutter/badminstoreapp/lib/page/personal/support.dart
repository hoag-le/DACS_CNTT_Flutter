import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Trung tâm hỗ trợ',
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '📞 Bạn cần hỗ trợ gì?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Chúng tôi luôn sẵn sàng hỗ trợ bạn mọi lúc. Nếu bạn gặp sự cố khi đặt hàng, cần tư vấn sản phẩm hoặc có phản hồi về dịch vụ, hãy liên hệ với chúng tôi qua các kênh sau:',
                style: TextStyle(fontSize: 16, color: Colors.brown),
              ),
              SizedBox(height: 20),
              Text(
                '📮 Kênh liên hệ:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '- Hotline: 0903535807 (từ 8h00 đến 21h00 hàng ngày)\n'
                '- Email: badminstore@gmail.com\n'
                '- Website: www.badminstore.vn/hotro\n'
                '- Fanpage: facebook.com/badminstore\n'
                '- Zalo OA: 0903535807',
                style: TextStyle(fontSize: 15, color: Colors.brown),
              ),
              SizedBox(height: 20),
              Text(
                '🔍 Các mục thường gặp:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '- Làm sao để đổi trả sản phẩm?\n'
                '- Tôi chưa nhận được đơn hàng?\n'
                '- Cách chọn size quần áo/váy?\n'
                '- Hướng dẫn căng vợt cầu lông đúng kỹ thuật?\n'
                '- Tư vấn chọn giày phù hợp theo mặt sân?',
                style: TextStyle(fontSize: 15, color: Colors.brown),
              ),
              SizedBox(height: 20),
              Text(
                '💬 Đừng ngại liên hệ với chúng tôi — Mọi thắc mắc đều đáng được lắng nghe và giải quyết. Cảm ơn bạn đã tin tưởng sử dụng dịch vụ của Cầu Lông Shop!',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
