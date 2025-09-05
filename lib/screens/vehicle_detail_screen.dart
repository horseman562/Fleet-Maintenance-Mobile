import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vehicle_provider.dart';
import '../models/vehicle.dart';
import 'odometer_update_screen.dart';
import 'service_submission_screen.dart';
import 'submission_history_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadVehicleDetails(widget.vehicleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedVehicle == null) {
            return const Scaffold(
              appBar: null,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.error != null && provider.selectedVehicle == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Vehicle Details')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text('Failed to load vehicle details'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          provider.loadVehicleDetails(widget.vehicleId),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final vehicle = provider.selectedVehicle!;

          return CustomScrollView(
            slivers: [
              // App Bar with Vehicle Info
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _getStatusColor(vehicle),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: _navigateToSubmissionHistory,
                    tooltip: 'View Submission History',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    vehicle.plateNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getStatusColor(vehicle),
                          _getStatusColor(vehicle).withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getVehicleIcon(vehicle.vehicleType),
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${vehicle.currentOdometer} km',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Health Assessment Card
                    _buildHealthAssessmentCard(vehicle),

                    // Quick Actions
                    _buildQuickActionsCard(vehicle),

                    // Upcoming Services
                    if (vehicle.healthAssessment.upcomingServices.isNotEmpty)
                      _buildUpcomingServicesCard(vehicle),

                    // Overdue Services
                    if (vehicle.healthAssessment.overdueServices.isNotEmpty)
                      _buildOverdueServicesCard(vehicle),

                    // Vehicle Info
                    _buildVehicleInfoCard(vehicle),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHealthAssessmentCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getHealthIcon(vehicle.healthAssessment.overallStatus),
                  color: _getStatusColorDark(vehicle),
                ),
                const SizedBox(width: 8),
                Text(
                  'Vehicle Health',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(vehicle).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    vehicle.statusText,
                    style: TextStyle(
                      color: _getStatusColorDark(vehicle),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHealthStat(
                  'Overdue',
                  vehicle.healthAssessment.overdueServices.length.toString(),
                  Colors.red,
                  Icons.error,
                ),
                _buildHealthStat(
                  'Due Soon',
                  vehicle.healthAssessment.upcomingServices.length.toString(),
                  Colors.amber,
                  Icons.schedule,
                ),
                _buildHealthStat(
                  'Est. Cost',
                  'RM ${vehicle.healthAssessment.totalEstimatedCost.toStringAsFixed(0)}',
                  Colors.blue,
                  Icons.attach_money,
                ),
              ],
            ),

            // Immediate Attention Banner
            if (vehicle.healthAssessment.immediateAttentionNeeded) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Immediate attention needed! Vehicle has overdue services.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateOdometer(vehicle),
                    icon: const Icon(Icons.speed),
                    label: const Text('Update KM'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add service record
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Service logging coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.build),
                    label: const Text('Log Service'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingServicesCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Due Soon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...vehicle.healthAssessment.upcomingServices.map(
              (service) => _buildServiceItem(service, Colors.amber, vehicle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueServicesCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Overdue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...vehicle.healthAssessment.overdueServices.map(
              (service) => _buildServiceItem(service, Colors.red, vehicle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service, Color color, Vehicle vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getServiceIcon(service.name),
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (service.dueDate != null)
                      Text(
                        'Due: ${service.dueDate}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (service.estimatedCost != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.formattedCost,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  if (service.dueOdometer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '@ ${service.dueOdometer} km',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  // Submit Receipt Button for overdue services
                  if (color == Colors.red && service.id != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () => _navigateToSubmitService(service),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Submit Receipt',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Detailed Status Information
          if (service.daysUntilDue != null || service.dueOdometer != null) ...[
            const SizedBox(height: 12),
            ..._buildStatusDetails(service, color, vehicle),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Make', vehicle.make),
            _buildInfoRow('Model', vehicle.model),
            _buildInfoRow('Year', vehicle.year.toString()),
            _buildInfoRow('Type', vehicle.vehicleType.toUpperCase()),
            _buildInfoRow('Current Odometer', '${vehicle.currentOdometer} km'),
            if (vehicle.notes != null && vehicle.notes!.isNotEmpty)
              _buildInfoRow('Notes', vehicle.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _updateOdometer(Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OdometerUpdateScreen(vehicle: vehicle),
      ),
    );
  }

  Color _getStatusColor(Vehicle vehicle) {
    switch (vehicle.statusColor) {
      case 'red':
        return Colors.red.shade600;
      case 'amber':
        return Colors.amber.shade600;
      default:
        return Colors.green.shade600;
    }
  }

  Color _getStatusColorDark(Vehicle vehicle) {
    switch (vehicle.statusColor) {
      case 'red':
        return Colors.red.shade700;
      case 'amber':
        return Colors.amber.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  IconData _getHealthIcon(String status) {
    switch (status) {
      case 'needs_attention':
        return Icons.error;
      case 'maintenance_due':
        return Icons.warning;
      default:
        return Icons.check_circle;
    }
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'truck':
      case 'lorry':
        return Icons.local_shipping;
      case 'van':
        return Icons.airport_shuttle;
      case 'motorcycle':
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('oil') || name.contains('minyak')) {
      return Icons.opacity;
    } else if (name.contains('brake') || name.contains('brek')) {
      return Icons.disc_full;
    } else if (name.contains('tire') ||
        name.contains('tyre') ||
        name.contains('tayar')) {
      return Icons.tire_repair;
    } else if (name.contains('engine')) {
      return Icons.engineering;
    } else if (name.contains('battery') || name.contains('bateri')) {
      return Icons.battery_charging_full;
    } else if (name.contains('filter')) {
      return Icons.air;
    } else {
      return Icons.build;
    }
  }

  Color _getStatusDetailColor(int daysUntilDue, Color fallbackColor) {
    if (daysUntilDue < 0) {
      return Colors.red.shade600;
    } else if (daysUntilDue <= 7) {
      return Colors.amber.shade600;
    } else if (daysUntilDue <= 30) {
      return Colors.orange.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  IconData _getStatusDetailIcon(int daysUntilDue) {
    if (daysUntilDue < 0) {
      return Icons.error;
    } else if (daysUntilDue <= 7) {
      return Icons.warning;
    } else if (daysUntilDue <= 30) {
      return Icons.schedule;
    } else {
      return Icons.info;
    }
  }

  String _getStatusDetailText(int daysUntilDue) {
    if (daysUntilDue < 0) {
      final daysOverdue = daysUntilDue.abs();
      return '$daysOverdue day${daysOverdue == 1 ? '' : 's'} overdue';
    } else if (daysUntilDue == 0) {
      return 'Due today!';
    } else if (daysUntilDue <= 7) {
      return '$daysUntilDue day${daysUntilDue == 1 ? '' : 's'} left';
    } else if (daysUntilDue <= 30) {
      return '$daysUntilDue days until due';
    } else {
      final weeks = (daysUntilDue / 7).round();
      return 'Due in $weeks week${weeks == 1 ? '' : 's'}';
    }
  }

  List<Widget> _buildStatusDetails(ServiceItem service, Color color, Vehicle vehicle) {
    final List<Widget> details = [];

    // Date-based status (always show if daysUntilDue is available)
    if (service.daysUntilDue != null) {
      details.add(_buildStatusDetailRow(
        _getStatusDetailIcon(service.daysUntilDue!),
        'Date: ${_getStatusDetailText(service.daysUntilDue!)}',
        _getStatusDetailColor(service.daysUntilDue!, color),
      ));
    }

    // Odometer-based status (show if service has due odometer)
    if (service.dueOdometer != null) {
      final odometerOverdue = _calculateOdometerOverdue(vehicle, service);
      String odometerText;
      
      if (odometerOverdue != null && odometerOverdue > 0) {
        // Service is overdue by odometer
        odometerText = 'Odometer: ${_formatNumber(odometerOverdue)} km overdue';
      } else {
        // Service is not yet due by odometer or exactly at due point
        final remaining = service.dueOdometer! - vehicle.currentOdometer;
        if (remaining > 0) {
          odometerText = 'Odometer: ${_formatNumber(remaining)} km remaining';
        } else {
          odometerText = 'Odometer: Due at ${_formatNumber(service.dueOdometer!)} km';
        }
      }

      if (service.daysUntilDue != null) {
        details.add(const SizedBox(height: 8));
      }
      
      details.add(_buildStatusDetailRow(
        Icons.speed,
        odometerText,
        odometerOverdue != null && odometerOverdue > 0 
            ? Colors.red.shade600 
            : _getStatusDetailColor(service.daysUntilDue ?? 1, color),
      ));
    }

    return details;
  }

  Widget _buildStatusDetailRow(IconData icon, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _calculateOdometerOverdue(Vehicle vehicle, ServiceItem service) {
    if (service.dueOdometer == null) return null;
    final overdue = vehicle.currentOdometer - service.dueOdometer!;
    return overdue > 0 ? overdue : null;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _navigateToSubmitService(ServiceItem service) {
    if (service.id != null) {
      final provider = context.read<VehicleProvider>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceSubmissionScreen(
            service: service,
            vehicle: provider.selectedVehicle!,
          ),
        ),
      );
    }
  }

  void _navigateToSubmissionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubmissionHistoryScreen(),
      ),
    );
  }
}
