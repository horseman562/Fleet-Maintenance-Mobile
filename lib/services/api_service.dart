import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.5:8000/api/mobile';
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<List<Vehicle>> getVehicles({String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/vehicles').replace(
        queryParameters: search != null ? {'search': search} : null,
      );
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> vehiclesJson = data['vehicles'];
        
        return vehiclesJson.map((json) => Vehicle.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Vehicle> getVehicleDetails(String vehicleId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles/$vehicleId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Vehicle.fromJson(data['vehicle']);
      } else if (response.statusCode == 404) {
        throw Exception('Vehicle not found');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load vehicle details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> updateOdometer(String vehicleId, int newOdometer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehicles/$vehicleId/odometer'),
        headers: _headers,
        body: json.encode({
          'current_odometer': newOdometer,
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Invalid odometer value');
      } else {
        throw Exception('Failed to update odometer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setAuthToken(data['token']);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  void logout() {
    _authToken = null;
  }
}