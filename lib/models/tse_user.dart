class TseUser {
  final String employeeId;
  final String name;
  final String email;
  final String designation;
  final String territory;
  final String hqCity;
  final String phone;
  final String buCode;
  final String buName;
  final String pic;
  final String divisionId;
  final String divisionName;
  final String region;
  final String state;

  TseUser({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.designation,
    required this.territory,
    required this.hqCity,
    required this.phone,
    required this.buCode,
    required this.buName,
    required this.pic,
    required this.divisionId,
    required this.divisionName,
    required this.region,
    required this.state,
  });

  factory TseUser.fromJson(Map<String, dynamic> json) {
    return TseUser(
      employeeId: json['employeeId'] ?? json['employee_id'] ?? '',
      name: json['employeeName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      designation: json['designation'] ?? 'TSE',
      territory: json['region'] ?? json['territory'] ?? '',
      hqCity: json['hq'] ?? json['hq_city'] ?? '',
      phone: json['mobile'] ?? json['phone'] ?? '',
      buCode: json['buCode'] ?? json['bu_code'] ?? '',
      buName: json['buName'] ?? json['bu_name'] ?? '',
      pic: json['pic'] ?? '',
      divisionId: json['divisionId'] ?? json['division_id'] ?? '',
      divisionName: json['divisionName'] ?? json['division_name'] ?? '',
      region: json['region'] ?? json['territory'] ?? '',
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'employee_id': employeeId,
        'employeeName': name,
        'name': name,
        'email': email,
        'designation': designation,
        'territory': territory,
        'hq_city': hqCity,
        'hq': hqCity,
        'phone': phone,
        'mobile': phone,
        'buCode': buCode,
        'bu_code': buCode,
        'buName': buName,
        'bu_name': buName,
        'pic': pic,
        'divisionId': divisionId,
        'division_id': divisionId,
        'divisionName': divisionName,
        'division_name': divisionName,
        'region': region,
        'state': state,
      };
}
