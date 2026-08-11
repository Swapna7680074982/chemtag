class Stockist {
  final String id;
  final String name;
  final String code;
  final String contactPerson;
  final String phone;
  final String address;
  final String city;
  final String tseEmployeeId;

  Stockist({
    required this.id,
    required this.name,
    required this.code,
    required this.contactPerson,
    required this.phone,
    required this.address,
    required this.city,
    required this.tseEmployeeId,
  });

  factory Stockist.fromJson(Map<String, dynamic> json) {
    return Stockist(
      id: json['stockistSapId'] ?? json['id'] ?? '',
      name: json['stockistName'] ?? json['name'] ?? '',
      code: json['stockistSapId'] ?? json['code'] ?? '',
      contactPerson: json['contactPerson'] ?? json['contact_person'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      address: json['hqName'] ?? json['address'] ?? '',
      city: json['hqName'] ?? json['city'] ?? '',
      tseEmployeeId: json['tseEmployeeId'] ?? json['tse_employee_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'contact_person': contactPerson,
        'phone': phone,
        'address': address,
        'city': city,
        'tse_employee_id': tseEmployeeId,
      };
}
