class Chemist {
  final String divisionCode;
  final String division;
  final String region;
  final String hq;
  final String empCode;
  final String empName;
  final String chemistcode;
  final String chemistName;
  final String mobileNumber;

  Chemist({
    String? divisionCode,
    String? division,
    String? region,
    String? hq,
    String? empCode,
    String? empName,
    String? chemistcode,
    String? chemistName,
    String? mobileNumber,
    // Legacy constructor compatibility
    String? id,
    String? storeName,
    String? ownerName,
    String? licenseNo,
    String? locality,
    String? city,
    String? phone,
    String? category,
    String? tseEmployeeId,
  })  : divisionCode = divisionCode ?? licenseNo ?? '',
        division = division ?? licenseNo ?? '',
        region = region ?? locality ?? '',
        hq = hq ?? city ?? '',
        empCode = empCode ?? tseEmployeeId ?? '',
        empName = empName ?? ownerName ?? '',
        chemistcode = chemistcode ?? id ?? '',
        chemistName = chemistName ?? storeName ?? '',
        mobileNumber = mobileNumber ?? phone ?? '';

  // Backward compatibility getters
  String get id => chemistcode;
  String get storeName => chemistName;
  String get ownerName => empName;
  String get licenseNo => division;
  String get locality => region;
  String get city => hq;
  String get phone => mobileNumber;
  String get category => 'A';
  String get tseEmployeeId => empCode;

  factory Chemist.fromJson(Map<String, dynamic> json) {
    return Chemist(
      divisionCode: json['divisionCode'] ?? json['division_code'] ?? '',
      division: json['division'] ?? '',
      region: json['region'] ?? '',
      hq: json['hq'] ?? '',
      empCode: json['empCode'] ?? json['emp_code'] ?? '',
      empName: json['empName'] ?? json['emp_name'] ?? '',
      chemistcode: json['chemistcode'] ?? json['chemistCode'] ?? '',
      chemistName: json['chemistName'] ?? json['chemist_name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? json['mobile_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'divisionCode': divisionCode,
        'division': division,
        'region': region,
        'hq': hq,
        'empCode': empCode,
        'empName': empName,
        'chemistcode': chemistcode,
        'chemistName': chemistName,
        'mobileNumber': mobileNumber,
      };
}
