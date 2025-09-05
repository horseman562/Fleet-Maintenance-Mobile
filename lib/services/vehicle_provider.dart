import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import 'api_service.dart';

class VehicleProvider with ChangeNotifier {
  static final ApiService _apiService = ApiService();
  
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<Vehicle> get filteredVehicles {
    if (_searchQuery.isEmpty) return _vehicles;
    
    return _vehicles.where((vehicle) {
      return vehicle.plateNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             vehicle.make.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             vehicle.model.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Vehicle> get needsAttentionVehicles {
    return _vehicles.where((vehicle) => 
      vehicle.healthAssessment.immediateAttentionNeeded
    ).toList();
  }

  List<Vehicle> get healthyVehicles {
    return _vehicles.where((vehicle) => 
      vehicle.healthAssessment.overallStatus == 'healthy'
    ).toList();
  }

  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadVehicles({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    _setLoading(true);
    _error = null;

    try {
      final vehicles = await _apiService.getVehicles();
      _vehicles = vehicles;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchVehicles(String query) async {
    _setLoading(true);
    _error = null;
    _searchQuery = query;

    try {
      final vehicles = await _apiService.getVehicles(search: query);
      _vehicles = vehicles;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadVehicleDetails(String vehicleId) async {
    _setLoading(true);
    _error = null;

    try {
      final vehicle = await _apiService.getVehicleDetails(vehicleId);
      _selectedVehicle = vehicle;
      
      // Update the vehicle in the main list if it exists
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = vehicle;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateVehicleOdometer(String vehicleId, int newOdometer) async {
    try {
      _error = null;
      final success = await _apiService.updateOdometer(vehicleId, newOdometer);
      
      if (success) {
        // Refresh the vehicle details to get updated health assessment
        await loadVehicleDetails(vehicleId);
        
        // Also refresh the vehicles list to show updated status
        await loadVehicles(refresh: true);
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSelectedVehicle() {
    _selectedVehicle = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}