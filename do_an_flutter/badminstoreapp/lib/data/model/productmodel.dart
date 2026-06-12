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

  ProductModel.fromFirestore(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'] as String?;
    productName = json['productName'] as String?;
    categoryId = (json['categoryId'] as num?)?.toInt();
    brandId = (json['brandId'] as num?)?.toInt();
    cost = (json['cost'] as num?)?.toInt();
    priceSale = (json['priceSale'] as num?)?.toInt();
    image = json['image'] as String?;
    status = (json['status'] as num?)?.toInt();
    visible = (json['visible'] as num?)?.toInt();
  }

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'] as String?;
    productName = json['productname'] as String? ?? json['productName'] as String?;
    categoryId = ((json['category_id'] ?? json['categoryId']) as num?)?.toInt();
    brandId = ((json['brand_id'] ?? json['brandId']) as num?)?.toInt();
    cost = (json['cost'] as num?)?.toInt();
    priceSale = ((json['pricesale'] ?? json['priceSale']) as num?)?.toInt();
    image = json['image'] as String?;
    status = (json['status'] as num?)?.toInt();
    visible = (json['visible'] as num?)?.toInt();
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'productName': productName,
      'categoryId': categoryId,
      'brandId': brandId,
      'cost': cost,
      'priceSale': priceSale,
      'image': image,
      'status': status,
      'visible': visible,
    };
  }
}
