import 'chemist.dart';
import 'stockist.dart';

class DcrItem {
  final String productId;
  final String productName;
  final String brandName;
  final String packSize;
  final int quantity;
  final double ptr;

  DcrItem({
    required this.productId,
    required this.productName,
    required this.brandName,
    required this.packSize,
    required this.quantity,
    required this.ptr,
  });

  double get totalPrice => ptr * quantity;

  factory DcrItem.fromJson(Map<String, dynamic> json) {
    return DcrItem(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      brandName: json['brand_name'] ?? '',
      packSize: json['pack_size'] ?? '',
      quantity: json['quantity'] ?? 0,
      ptr: (json['ptr'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'brand_name': brandName,
        'pack_size': packSize,
        'quantity': quantity,
        'ptr': ptr,
        'total_price': totalPrice,
      };
}

class DcrSubmission {
  final String id;
  final String tseEmployeeId;
  final String tseName;
  final Chemist chemist;
  final List<Stockist> selectedStockists;
  final List<DcrItem> items;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime submittedAt;
  final String notes;

  DcrSubmission({
    required this.id,
    required this.tseEmployeeId,
    required this.tseName,
    required this.chemist,
    required this.selectedStockists,
    required this.items,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.submittedAt,
    this.notes = '',
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalValue => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  factory DcrSubmission.fromJson(Map<String, dynamic> json) {
    return DcrSubmission(
      id: json['id'] ?? '',
      tseEmployeeId: json['tse_employee_id'] ?? '',
      tseName: json['tse_name'] ?? '',
      chemist: Chemist.fromJson(json['chemist']),
      selectedStockists: (json['selected_stockists'] as List)
          .map((s) => Stockist.fromJson(s))
          .toList(),
      items: (json['items'] as List).map((i) => DcrItem.fromJson(i)).toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyMeters: (json['accuracy_meters'] as num).toDouble(),
      submittedAt: DateTime.parse(json['submitted_at']),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tse_employee_id': tseEmployeeId,
        'tse_name': tseName,
        'chemist': chemist.toJson(),
        'selected_stockists': selectedStockists.map((s) => s.toJson()).toList(),
        'items': items.map((i) => i.toJson()).toList(),
        'latitude': latitude,
        'longitude': longitude,
        'accuracy_meters': accuracyMeters,
        'submitted_at': submittedAt.toIso8601String(),
        'notes': notes,
        'total_quantity': totalQuantity,
        'total_value': totalValue,
      };
}
