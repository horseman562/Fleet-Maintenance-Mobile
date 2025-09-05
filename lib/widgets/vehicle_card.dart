import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final VoidCallback? onUpdateOdometer;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.onUpdateOdometer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getVehicleIcon(),
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.plateNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          vehicle.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stats Row
              Row(
                children: [
                  _buildStatItem(
                    Icons.speed,
                    '${vehicle.currentOdometer.toString()} km',
                    'Odometer',
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    Icons.build,
                    '${vehicle.healthAssessment.overdueServices.length + vehicle.healthAssessment.upcomingServices.length}',
                    'Services',
                  ),
                  const Spacer(),
                  if (vehicle.healthAssessment.totalEstimatedCost > 0)
                    _buildStatItem(
                      Icons.attach_money,
                      'RM ${vehicle.healthAssessment.totalEstimatedCost.toStringAsFixed(0)}',
                      'Due Cost',
                    ),
                ],
              ),
              
              // Service Summary
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
                      Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${vehicle.healthAssessment.overdueServices.length} service(s) overdue',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (vehicle.healthAssessment.upcomingServices.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.amber.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getNextServiceText(),
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action Buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUpdateOdometer,
                      icon: const Icon(Icons.speed, size: 18),
                      label: const Text('Update KM'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;
    
    switch (vehicle.statusColor) {
      case 'red':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'amber':
        color = Colors.amber;
        icon = Icons.warning;
        break;
      default:
        color = Colors.green;
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            vehicle.statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (vehicle.statusColor) {
      case 'red':
        return Colors.red.shade300;
      case 'amber':
        return Colors.amber.shade300;
      default:
        return Colors.green.shade300;
    }
  }

  IconData _getVehicleIcon() {
    switch (vehicle.vehicleType.toLowerCase()) {
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

  String _getNextServiceText() {
    if (vehicle.healthAssessment.upcomingServices.isEmpty) return '';
    
    final nextService = vehicle.healthAssessment.upcomingServices.first;
    final daysText = nextService.daysUntilDue != null 
        ? 'in ${nextService.daysUntilDue} days'
        : 'soon';
    
    return '${nextService.name} due $daysText';
  }
}