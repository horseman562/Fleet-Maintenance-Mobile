import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vehicle_provider.dart';
import '../widgets/vehicle_card.dart';
import 'vehicle_detail_screen.dart';
import 'odometer_update_screen.dart';

class VehicleSearchScreen extends StatefulWidget {
  const VehicleSearchScreen({super.key});

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VehicleProvider>();
      provider.loadVehicles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Vehicles'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            color: Colors.blue.shade600,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search by plate number, make, or model...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _performSearch(value);
                    },
                    onSubmitted: _performSearch,
                  ),
                ),
                const SizedBox(height: 16),
                // Quick Stats
                Consumer<VehicleProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      children: [
                        _buildQuickStat(
                          'Total',
                          provider.vehicles.length.toString(),
                          Colors.white,
                        ),
                        const SizedBox(width: 16),
                        _buildQuickStat(
                          'Needs Attention',
                          provider.needsAttentionVehicles.length.toString(),
                          Colors.red.shade100,
                        ),
                        const SizedBox(width: 16),
                        _buildQuickStat(
                          'Healthy',
                          provider.healthyVehicles.length.toString(),
                          Colors.green.shade100,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Filter Tabs
          Container(
            color: Colors.grey.shade100,
            child: Consumer<VehicleProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip('All', provider.vehicles.length, true),
                      const SizedBox(width: 8),
                      _buildFilterChip('Attention', provider.needsAttentionVehicles.length, false),
                      const SizedBox(width: 8),
                      _buildFilterChip('Healthy', provider.healthyVehicles.length, false),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Vehicle List
          Expanded(
            child: Consumer<VehicleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.vehicles.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadVehicles(refresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final vehicles = provider.filteredVehicles;

                if (vehicles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.searchQuery.isEmpty 
                              ? 'No vehicles found'
                              : 'No vehicles match your search',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (provider.searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadVehicles(refresh: true),
                  child: ListView.builder(
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return VehicleCard(
                        vehicle: vehicle,
                        onTap: () => _viewVehicleDetails(vehicle.id),
                        onUpdateOdometer: () => _updateOdometer(vehicle),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color backgroundColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, bool isSelected) {
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filtering logic
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue.shade100,
    );
  }

  void _performSearch(String query) {
    final provider = context.read<VehicleProvider>();
    provider.updateSearchQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
    _searchFocusNode.unfocus();
  }

  void _viewVehicleDetails(String vehicleId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VehicleDetailScreen(vehicleId: vehicleId),
      ),
    );
  }

  void _updateOdometer(vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OdometerUpdateScreen(vehicle: vehicle),
      ),
    );
  }
}