class ProductModel {
  dynamic id;
  String? code;
  String? productName;
  int? categoryId;
  int? brandId;
  int? cost;
  int? priceSale;
  String? image;
  int? status;
  int? visible;

  ProductModel({
    this.id,
    this.code,
    this.productName,
    this.categoryId,
    this.brandId,
    this.cost,
    this.priceSale,
    this.image,
    this.status,
    this.visible,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    productName = json['productname'] ?? json['productName'];
    categoryId = json['category_id'] ?? json['categoryId'];
    brandId = json['brand_id'] ?? json['brandId'];
    cost = json['cost'];
    priceSale = json['pricesale'] ?? json['priceSale'];
    image = json['image'];
    status = json['status'];
    visible = json['visible'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'productname': productName,
      'category_id': categoryId,
      'brand_id': brandId,
      'cost': cost,
      'pricesale': priceSale,
      'image': image,
      'status': status,
      'visible': visible,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'productName': productName,
      'categoryId': categoryId,
      'brandId': brandId,
      'cost': cost,
      'priceSale': priceSale,
      'image': image,
      'status': status ?? 1,
      'visible': visible ?? 1,
    };
  }
}