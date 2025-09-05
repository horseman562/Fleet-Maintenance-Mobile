class ServiceSubmission {
  final String id;
  final String serviceType;
  final String vehiclePlate;
  final DateTime serviceDate;
  final double cost;
  final String status;
  final String? workshopName;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? adminNotes;

  ServiceSubmission({
    required this.id,
    required this.serviceType,
    required this.vehiclePlate,
    required this.serviceDate,
    required this.cost,
    required this.status,
    this.workshopName,
    required this.submittedAt,
    this.reviewedAt,
    this.adminNotes,
  });

  factory ServiceSubmission.fromJson(Map<String, dynamic> json) {
    return ServiceSubmission(
      id: json['id'] ?? '',
      serviceType: json['service_type'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      serviceDate: DateTime.tryParse(json['service_date'] ?? '') ?? DateTime.now(),
      cost: _parseDouble(json['cost']),
      status: json['status'] ?? 'pending',
      workshopName: json['workshop_name'],
      submittedAt: DateTime.tryParse(json['submitted_at'] ?? '') ?? DateTime.now(),
      reviewedAt: json['reviewed_at'] != null 
          ? DateTime.tryParse(json['reviewed_at']) 
          : null,
      adminNotes: json['admin_notes'],
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String get statusColor {
    switch (status) {
      case 'pending':
        return 'amber';
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      default:
        return 'grey';
    }
  }

  String get formattedCost => 'RM ${cost.toStringAsFixed(2)}';
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}