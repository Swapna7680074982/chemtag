class Product {
  final String productId;
  final String productCode;
  final String materialCode;
  final String productName;
  final String materialName;
  final String divisionCode;
  final String packSize;
  final String unit;

  Product({
    required String id,
    required String name,
    required String skuCode,
    required String brandId,
    required String brandName,
    required this.packSize,
    String? tseEmployeeId,
    String? unit,
    String? productCode,
    String? materialCode,
    String? productName,
    String? materialName,
    String? divisionCode,
  })  : productId = id,
        productName = productName ?? name,
        materialCode = materialCode ?? skuCode,
        divisionCode = divisionCode ?? brandId,
        productCode = productCode ?? id,
        materialName = materialName ?? name,
        unit = unit ?? '';

  // Backward compatibility getters
  String get id => productId;
  String get name => productName;
  String get skuCode => materialCode;
  String get brandId => divisionCode;
  String get brandName => "Division $divisionCode";
  bool get inStock => true;
  String get tseEmployeeId => '';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['productId'] ?? json['productCode'] ?? json['id'] ?? '',
      name: json['productName'] ?? json['materialName'] ?? json['name'] ?? '',
      skuCode: json['materialCode'] ?? json['sku_code'] ?? '',
      brandId: json['divisionCode'] ?? json['brand_id'] ?? '',
      brandName: json['divisionName'] ?? (json['divisionCode'] != null ? "Division ${json['divisionCode']}" : json['brand_name'] ?? ''),
      packSize: json['packSize'] ?? json['pack_size'] ?? '',
      unit: json['unit'] ?? '',
      productCode: json['productCode'] ?? '',
      materialName: json['materialName'] ?? '',
      divisionCode: json['divisionCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productCode': productCode,
        'materialCode': materialCode,
        'productName': productName,
        'materialName': materialName,
        'divisionCode': divisionCode,
        'packSize': packSize,
        'unit': unit,
      };
}
