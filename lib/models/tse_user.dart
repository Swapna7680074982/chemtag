class TseUser {
  final String employeeId;
  final String name;
  final String email;
  final String designation;
  final String territory;
  final String hqCity;
  final String phone;

  TseUser({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.designation,
    required this.territory,
    required this.hqCity,
    required this.phone,
  });

  factory TseUser.fromJson(Map<String, dynamic> json) {
    return TseUser(
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      designation: json['designation'] ?? 'Territory Sales Executive',
      territory: json['territory'] ?? '',
      hqCity: json['hq_city'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'employee_id': employeeId,
        'name': name,
        'email': email,
        'designation': designation,
        'territory': territory,
        'hq_city': hqCity,
        'phone': phone,
      };
}
