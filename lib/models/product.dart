class Product {
  final String id;
  final String name;
  final String skuCode;
  final String brandId;
  final String brandName;
  final String packSize;
  final double ptr;
  final double mrp;
  final bool inStock;
  final List<String> availableStockistIds;

  Product({
    required this.id,
    required this.name,
    required this.skuCode,
    required this.brandId,
    required this.brandName,
    required this.packSize,
    required this.ptr,
    required this.mrp,
    this.inStock = true,
    required this.availableStockistIds,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      skuCode: json['sku_code'] ?? '',
      brandId: json['brand_id'] ?? '',
      brandName: json['brand_name'] ?? '',
      packSize: json['pack_size'] ?? '',
      ptr: (json['ptr'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      inStock: json['in_stock'] ?? true,
      availableStockistIds: List<String>.from(json['available_stockist_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku_code': skuCode,
        'brand_id': brandId,
        'brand_name': brandName,
        'pack_size': packSize,
        'ptr': ptr,
        'mrp': mrp,
        'in_stock': inStock,
        'available_stockist_ids': availableStockistIds,
      };
}
