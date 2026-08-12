import 'chemist.dart';
import 'stockist.dart';

class DcrItem {
  final String productId;
  final String productName;
  final String brandName;
  final String packSize;
  final int quantity;
  final String stockistId;
  final String stockistName;

  DcrItem({
    required this.productId,
    required this.productName,
    required this.brandName,
    required this.packSize,
    required this.quantity,
    required this.stockistId,
    required this.stockistName,
  });

  factory DcrItem.fromJson(Map<String, dynamic> json) {
    return DcrItem(
      productId: json['productId'] ?? json['product_id'] ?? json['materialCode'] ?? '',
      productName: json['productName'] ?? json['product_name'] ?? json['materialName'] ?? '',
      brandName: json['divisionCode'] ?? json['brand_name'] ?? '',
      packSize: json['packSize'] ?? json['pack_size'] ?? '',
      quantity: json['quantity'] is int 
          ? json['quantity'] 
          : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      stockistId: json['stockist_id'] ?? '',
      stockistName: json['stockist_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'brand_name': brandName,
        'pack_size': packSize,
        'quantity': quantity,
        'stockist_id': stockistId,
        'stockist_name': stockistName,
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

  factory DcrSubmission.fromJson(Map<String, dynamic> json) {
    final chemistMap = json['chemistDetails'] ?? json['chemist'];
    Chemist chemistObj;
    if (chemistMap is Map<String, dynamic>) {
      chemistObj = Chemist.fromJson(chemistMap);
    } else {
      chemistObj = Chemist(
        id: '',
        storeName: 'Unknown Store',
        ownerName: '',
        licenseNo: '',
        locality: '',
        city: '',
        phone: '',
        category: '',
        tseEmployeeId: '',
      );
    }

    final locationMap = json['locationDetails'] ?? json['location'];
    double lat = 0.0;
    double lng = 0.0;
    double acc = 0.0;
    if (locationMap is Map<String, dynamic>) {
      lat = (locationMap['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (locationMap['longitude'] as num?)?.toDouble() ?? 0.0;
      acc = (locationMap['gpsAccuracyMeters'] as num?)?.toDouble() ?? 10.0;
    } else {
      lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
      acc = (json['accuracy_meters'] as num?)?.toDouble() ?? 10.0;
    }

    final orderDetails = json['orderDetails'];
    String orderId = '';
    String orderNo = '';
    String remarks = '';
    String submittedAtStr = '';
    if (orderDetails is Map<String, dynamic>) {
      orderId = orderDetails['orderId']?.toString() ?? '';
      orderNo = orderDetails['orderNo'] ?? '';
      remarks = orderDetails['remarks'] ?? '';
      submittedAtStr = orderDetails['submittedAt'] ?? '';
    } else {
      orderNo = json['orderNo'] ?? json['id'] ?? json['orderId']?.toString() ?? '';
      remarks = json['remarks'] ?? json['notes'] ?? '';
      submittedAtStr = json['submittedAt'] ?? json['submitted_at'] ?? '';
    }

    DateTime submittedDate;
    try {
      submittedDate = DateTime.parse(submittedAtStr);
    } catch (_) {
      submittedDate = DateTime.now();
    }

    final stockistsList = <Stockist>[];
    final itemsList = <DcrItem>[];

    // Check if new structure is present inside chemistDetails:
    final chemistDetails = json['chemistDetails'];
    if (chemistDetails is Map<String, dynamic> && chemistDetails['stockistDetails'] is List) {
      final stockistDetailsList = chemistDetails['stockistDetails'] as List;
      for (final sObj in stockistDetailsList) {
        if (sObj is Map<String, dynamic>) {
          final stockist = Stockist.fromJson(sObj);
          stockistsList.add(stockist);

          final productDetailsList = sObj['productDetails'];
          if (productDetailsList is List) {
            for (final pObj in productDetailsList) {
              if (pObj is Map<String, dynamic>) {
                final item = DcrItem(
                  productId: pObj['productId'] ?? pObj['product_id'] ?? pObj['materialCode'] ?? '',
                  productName: pObj['productName'] ?? pObj['product_name'] ?? pObj['materialName'] ?? '',
                  brandName: pObj['brandName'] ?? pObj['brand_name'] ?? pObj['divisionCode'] ?? '',
                  packSize: pObj['packSize']?.toString() ?? pObj['pack_size']?.toString() ?? '',
                  quantity: pObj['quantity'] is int 
                      ? pObj['quantity'] 
                      : int.tryParse(pObj['quantity']?.toString() ?? '0') ?? 0,
                  stockistId: stockist.id,
                  stockistName: stockist.name,
                );
                itemsList.add(item);
              }
            }
          }
        }
      }
    } else {
      final itemsRaw = json['items'] as List?;
      if (itemsRaw != null) {
        itemsList.addAll(itemsRaw.map((i) => DcrItem.fromJson(i as Map<String, dynamic>)));
      }

      final stockistsRaw = json['stockists'] as List?;
      if (stockistsRaw != null) {
        stockistsList.addAll(stockistsRaw.map((s) => Stockist.fromJson(s as Map<String, dynamic>)));
      }
    }

    return DcrSubmission(
      id: orderNo.isNotEmpty ? orderNo : (orderId.isNotEmpty ? orderId : 'DCR-SUBMISSION'),
      tseEmployeeId: json['tse_employee_id'] ?? '',
      tseName: json['tse_name'] ?? '',
      chemist: chemistObj,
      selectedStockists: stockistsList,
      items: itemsList,
      latitude: lat,
      longitude: lng,
      accuracyMeters: acc,
      submittedAt: submittedDate,
      notes: remarks,
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
      };
}
