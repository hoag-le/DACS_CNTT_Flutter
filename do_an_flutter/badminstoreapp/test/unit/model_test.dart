import 'package:flutter_test/flutter_test.dart';
import 'package:badminstoreapp/data/model/productmodel.dart';
import 'package:badminstoreapp/data/model/usermodel.dart';

void main() {
  group('ProductModel Tests', () {
    test('fromJson and toJson map correctly', () {
      final json = {
        'id': 1,
        'code': 'P001',
        'productname': 'Test Product',
        'category_id': 2,
        'brand_id': 3,
        'cost': 100000,
        'pricesale': 80000,
        'image': 'test.png',
        'status': 1,
        'visible': 1,
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 1);
      expect(product.productName, 'Test Product');
      expect(product.priceSale, 80000);

      final exportedJson = product.toJson();
      expect(exportedJson['productname'], 'Test Product');
      expect(exportedJson['pricesale'], 80000);
    });

    test('toFirestore formats correctly', () {
      final product = ProductModel(
        code: 'P001',
        productName: 'Test Product',
        categoryId: 2,
        brandId: 3,
        cost: 100000,
        priceSale: 80000,
        image: 'test.png',
      );

      final firestoreJson = product.toFirestore();

      expect(firestoreJson['productName'], 'Test Product');
      expect(firestoreJson['priceSale'], 80000);
      expect(firestoreJson['status'], 1); // Default value test
      expect(firestoreJson['visible'], 1); // Default value test
    });
  });

  group('UserModel Tests', () {
    test('fromJson and toJson map correctly', () {
      final json = {
        'uid': 'user_1',
        'username': 'johndoe',
        'email': 'john@example.com',
        'fullname': 'John Doe',
        'role': 0,
        'status': 1,
        'login_type': 'local',
      };

      final user = UserModel.fromJson(json);

      expect(user.uid, 'user_1');
      expect(user.username, 'johndoe');
      expect(user.email, 'john@example.com');
      expect(user.loginType, 'local');

      final exportedJson = user.toJson();
      expect(exportedJson['username'], 'johndoe');
      expect(exportedJson['login_type'], 'local');
    });
  });
}
