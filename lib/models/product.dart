class Product {
  final String id;
  final String name;
  final String skuCode;
  final String brandId;
  final String brandName;
  final String packSize;
  final bool inStock;
  final String tseEmployeeId;

  Product({
    required this.id,
    required this.name,
    required this.skuCode,
    required this.brandId,
    required this.brandName,
    required this.packSize,
    this.inStock = true,
    required this.tseEmployeeId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['productId'] ?? json['productCode'] ?? json['id'] ?? '',
      name: json['productName'] ?? json['materialName'] ?? json['name'] ?? '',
      skuCode: json['materialCode'] ?? json['sku_code'] ?? '',
      brandId: json['divisionCode'] ?? json['brand_id'] ?? '',
      brandName: json['divisionName'] ?? (json['divisionCode'] != null ? "Division ${json['divisionCode']}" : json['brand_name'] ?? ''),
      packSize: json['packSize'] ?? json['pack_size'] ?? '',
      inStock: json['in_stock'] ?? true,
      tseEmployeeId: json['tse_employee_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku_code': skuCode,
        'brand_id': brandId,
        'brand_name': brandName,
        'pack_size': packSize,
        'in_stock': inStock,
        'tse_employee_id': tseEmployeeId,
      };
}
