class Stockist {
  final String stockistSapId;
  final String stockistName;
  final String divisionSapId;
  final String citySapId;
  final String hqName;

  Stockist({
    String? stockistSapId,
    String? stockistName,
    String? divisionSapId,
    String? citySapId,
    String? hqName,
    // Legacy constructor compatibility
    String? id,
    String? name,
    String? code,
    String? contactPerson,
    String? phone,
    String? address,
    String? city,
    String? tseEmployeeId,
  })  : stockistSapId = stockistSapId ?? code ?? id ?? '',
        stockistName = stockistName ?? name ?? '',
        divisionSapId = divisionSapId ?? '',
        citySapId = citySapId ?? '',
        hqName = hqName ?? address ?? city ?? '';

  // Backward compatibility getters
  String get id => stockistSapId;
  String get name => stockistName;
  String get code => stockistSapId;
  String get contactPerson => 'N/A';
  String get phone => 'N/A';
  String get address => hqName;
  String get city => hqName;
  String get tseEmployeeId => '';

  factory Stockist.fromJson(Map<String, dynamic> json) {
    return Stockist(
      stockistSapId: json['stockistSapId'] ?? json['stockist_sap_id'] ?? '',
      stockistName: json['stockistName'] ?? json['stockist_name'] ?? '',
      divisionSapId: json['divisionSapId'] ?? json['division_sap_id'] ?? '',
      citySapId: json['citySapId'] ?? json['city_sap_id'] ?? '',
      hqName: json['hqName'] ?? json['hq_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'stockistSapId': stockistSapId,
        'stockistName': stockistName,
        'divisionSapId': divisionSapId,
        'citySapId': citySapId,
        'hqName': hqName,
      };
}
