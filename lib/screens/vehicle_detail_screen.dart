import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vehicle_provider.dart';
import '../models/vehicle.dart';
import 'odometer_update_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({
    super.key,
    required this.vehicleId,
  });

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
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Failed to load vehicle details'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadVehicleDetails(widget.vehicleId),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                ),
                _buildHealthStat(
                  'Due Soon',
                  vehicle.healthAssessment.upcomingServices.length.toString(),
                  Colors.amber,
                ),
                _buildHealthStat(
                  'Est. Cost',
                  'RM ${vehicle.healthAssessment.totalEstimatedCost.toStringAsFixed(0)}',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                        const SnackBar(content: Text('Service logging coming soon!')),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...vehicle.healthAssessment.upcomingServices.map(
              (service) => _buildServiceItem(service, Colors.amber),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...vehicle.healthAssessment.overdueServices.map(
              (service) => _buildServiceItem(service, Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.build,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (service.dueDate != null)
                  Text(
                    'Due: ${service.dueDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          if (service.estimatedCost != null)
            Text(
              service.formattedCost,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
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
}