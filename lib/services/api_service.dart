import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import '../config/local_config.dart';

class ApiService {
  static String get baseUrl => LocalConfig.localApiUrl;
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

  Future<Map<String, dynamic>> submitService({
    required String serviceScheduleId,
    required String serviceDate,
    required int odometerReading,
    required double cost,
    String? workshopName,
    String? serviceProvider,
    String? workshopContact,
    String? notes,
    List<String>? receiptPhotos,
    List<String>? servicePhotos,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/service/submit'),
      );
      
      // Add headers
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      request.headers['Accept'] = 'application/json';
      
      // Add form fields
      request.fields['service_schedule_id'] = serviceScheduleId;
      request.fields['service_date'] = serviceDate;
      request.fields['odometer_reading'] = odometerReading.toString();
      request.fields['cost'] = cost.toString();
      
      if (workshopName != null) request.fields['workshop_name'] = workshopName;
      if (serviceProvider != null) request.fields['service_provider'] = serviceProvider;
      if (workshopContact != null) request.fields['workshop_contact'] = workshopContact;
      if (notes != null) request.fields['notes'] = notes;
      
      // Add receipt photos
      if (receiptPhotos != null) {
        for (int i = 0; i < receiptPhotos.length; i++) {
          var file = File(receiptPhotos[i]);
          if (await file.exists()) {
            request.files.add(await http.MultipartFile.fromPath(
              'receipt_photos[]',
              receiptPhotos[i],
            ));
          }
        }
      }
      
      // Add service photos
      if (servicePhotos != null) {
        for (int i = 0; i < servicePhotos.length; i++) {
          var file = File(servicePhotos[i]);
          if (await file.exists()) {
            request.files.add(await http.MultipartFile.fromPath(
              'service_photos[]',
              servicePhotos[i],
            ));
          }
        }
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (response.statusCode == 422) {
        final data = json.decode(responseBody);
        throw Exception(data['message'] ?? 'Invalid submission data');
      } else {
        throw Exception('Failed to submit service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getSubmissions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/submissions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['submissions'] ?? [];
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}