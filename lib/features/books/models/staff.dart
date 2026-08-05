class Staff {
  final String id;
  final String ownerId;
  final String name;
  final String phone;
  final String? cnic;
  final String salaryType; // 'monthly', 'weekly', 'daily', 'hourly'
  final double salaryAmount;
  final String? workingHours;
  final DateTime? joiningDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Staff({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phone,
    this.cnic,
    required this.salaryType,
    required this.salaryAmount,
    this.workingHours,
    this.joiningDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      cnic: json['cnic'] as String?,
      salaryType: json['salary_type'] as String,
      salaryAmount: (json['salary_amount'] as num).toDouble(),
      workingHours: json['working_hours'] as String?,
      joiningDate: json['joining_date'] != null ? DateTime.parse(json['joining_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (cnic != null) 'cnic': cnic,
      'salary_type': salaryType,
      'salary_amount': salaryAmount,
      if (workingHours != null) 'working_hours': workingHours,
      if (joiningDate != null) 'joining_date': joiningDate!.toIso8601String().split('T')[0], // date format
    };
  }
}

class StaffAttendance {
  final String id;
  final String ownerId;
  final String staffId;
  final DateTime date;
  final String status; // 'present', 'absent', 'half_day', 'late'
  final DateTime createdAt;

  StaffAttendance({
    required this.id,
    required this.ownerId,
    required this.staffId,
    required this.date,
    required this.status,
    required this.createdAt,
  });

  factory StaffAttendance.fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      staffId: json['staff_id'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'date': date.toIso8601String().split('T')[0],
      'status': status,
    };
  }
}

class StaffPayroll {
  final String id;
  final String ownerId;
  final String staffId;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  StaffPayroll({
    required this.id,
    required this.ownerId,
    required this.staffId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  factory StaffPayroll.fromJson(Map<String, dynamic> json) {
    return StaffPayroll(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      staffId: json['staff_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      if (note != null) 'note': note,
    };
  }
}
