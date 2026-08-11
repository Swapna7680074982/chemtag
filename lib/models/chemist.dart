class Chemist {
  final String id;
  final String storeName;
  final String ownerName;
  final String licenseNo;
  final String locality;
  final String city;
  final String phone;
  final String category;
  final String tseEmployeeId;

  Chemist({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.licenseNo,
    required this.locality,
    required this.city,
    required this.phone,
    required this.category,
    required this.tseEmployeeId,
  });

  factory Chemist.fromJson(Map<String, dynamic> json) {
    return Chemist(
      id: json['chemistcode'] ?? json['chemistId'] ?? json['id'] ?? '',
      storeName: json['chemistName'] ?? json['store_name'] ?? '',
      ownerName: json['empName'] ?? json['owner_name'] ?? '',
      licenseNo: json['division'] ?? json['license_no'] ?? 'N/A',
      locality: json['region'] ?? json['locality'] ?? '',
      city: json['hq'] ?? json['city'] ?? '',
      phone: json['mobileNumber'] ?? json['phone'] ?? '',
      category: json['category'] ?? 'A',
      tseEmployeeId: json['empCode'] ?? json['tse_employee_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'store_name': storeName,
        'owner_name': ownerName,
        'license_no': licenseNo,
        'locality': locality,
        'city': city,
        'phone': phone,
        'category': category,
        'tse_employee_id': tseEmployeeId,
      };
}
