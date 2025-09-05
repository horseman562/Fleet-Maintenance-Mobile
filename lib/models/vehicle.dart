class Vehicle {
  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final String vehicleType;
  final int currentOdometer;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final HealthAssessment healthAssessment;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.vehicleType,
    required this.currentOdometer,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.healthAssessment,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      vehicleType: json['vehicle_type'] ?? '',
      currentOdometer: json['current_odometer'] ?? 0,
      isActive: json['is_active'] ?? true,
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      healthAssessment: HealthAssessment.fromJson(json['health_assessment'] ?? {}),
    );
  }

  String get displayName => '$year $make $model ($plateNumber)';
  
  String get statusColor {
    switch (healthAssessment.overallStatus) {
      case 'needs_attention':
        return 'red';
      case 'maintenance_due':
        return 'amber';
      case 'healthy':
      default:
        return 'green';
    }
  }
  
  String get statusText {
    switch (healthAssessment.overallStatus) {
      case 'needs_attention':
        return 'Needs Attention';
      case 'maintenance_due':
        return 'Maintenance Due';
      case 'healthy':
      default:
        return 'Healthy';
    }
  }
}

class HealthAssessment {
  final String overallStatus;
  final bool immediateAttentionNeeded;
  final List<ServiceItem> overdueServices;
  final List<ServiceItem> upcomingServices;
  final double totalEstimatedCost;

  HealthAssessment({
    required this.overallStatus,
    required this.immediateAttentionNeeded,
    required this.overdueServices,
    required this.upcomingServices,
    required this.totalEstimatedCost,
  });

  factory HealthAssessment.fromJson(Map<String, dynamic> json) {
    return HealthAssessment(
      overallStatus: json['overall_status'] ?? 'unknown',
      immediateAttentionNeeded: json['immediate_attention_needed'] ?? false,
      overdueServices: (json['overdue_services'] as List? ?? [])
          .map((item) => ServiceItem.fromJson(item))
          .toList(),
      upcomingServices: (json['upcoming_services'] as List? ?? [])
          .map((item) => ServiceItem.fromJson(item))
          .toList(),
      totalEstimatedCost: _parseDouble(json['total_estimated_cost']) ?? 0.0,
    );
  }
}

class ServiceItem {
  final String name;
  final String? icon;
  final double? estimatedCost;
  final String? dueDate;
  final int? dueOdometer;
  final int? daysUntilDue;

  ServiceItem({
    required this.name,
    this.icon,
    this.estimatedCost,
    this.dueDate,
    this.dueOdometer,
    this.daysUntilDue,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      name: json['name'] ?? '',
      icon: json['icon'],
      estimatedCost: _parseDouble(json['estimated_cost']),
      dueDate: json['due_date'],
      dueOdometer: json['due_odometer'],
      daysUntilDue: json['days_until_due'],
    );
  }

  String get formattedCost => estimatedCost != null 
      ? 'RM ${estimatedCost!.toStringAsFixed(2)}'
      : '';
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}