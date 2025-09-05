import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/vehicle_provider.dart';
import '../models/vehicle.dart';

class ServiceSubmissionScreen extends StatefulWidget {
  final ServiceItem service;
  final Vehicle vehicle;

  const ServiceSubmissionScreen({
    super.key,
    required this.service,
    required this.vehicle,
  });

  @override
  State<ServiceSubmissionScreen> createState() => _ServiceSubmissionScreenState();
}

class _ServiceSubmissionScreenState extends State<ServiceSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceDateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _workshopNameController = TextEditingController();
  final _serviceProviderController = TextEditingController();
  final _workshopContactController = TextEditingController();
  final _notesController = TextEditingController();

  final List<File> _receiptPhotos = [];
  final List<File> _servicePhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _serviceDateController.text = _formatDate(DateTime.now());
    _odometerController.text = widget.vehicle.currentOdometer.toString();
    _costController.text = widget.service.estimatedCost?.toStringAsFixed(2) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Service Receipt'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Info Card
              _buildServiceInfoCard(),
              const SizedBox(height: 20),

              // Service Details
              _buildServiceDetailsSection(),
              const SizedBox(height: 20),

              // Workshop Information
              _buildWorkshopSection(),
              const SizedBox(height: 20),

              // Receipt Photos
              _buildReceiptPhotosSection(),
              const SizedBox(height: 20),

              // Service Photos
              _buildServicePhotosSection(),
              const SizedBox(height: 20),

              // Notes
              _buildNotesSection(),
              const SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Service Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Service Type', widget.service.name),
            _buildInfoRow('Vehicle', '${widget.vehicle.plateNumber} - ${widget.vehicle.displayName}'),
            if (widget.service.dueDate != null)
              _buildInfoRow('Originally Due', widget.service.dueDate!),
            if (widget.service.estimatedCost != null)
              _buildInfoRow('Estimated Cost', widget.service.formattedCost),
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

  Widget _buildServiceDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Service Date
            TextFormField(
              controller: _serviceDateController,
              decoration: const InputDecoration(
                labelText: 'Service Date *',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select service date';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Odometer Reading
            TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Odometer Reading (km) *',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter odometer reading';
                }
                final odometer = int.tryParse(value);
                if (odometer == null || odometer < 0) {
                  return 'Please enter valid odometer reading';
                }
                if (odometer < widget.vehicle.currentOdometer) {
                  return 'Odometer cannot be less than current reading';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Cost
            TextFormField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Cost (RM) *',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter service cost';
                }
                final cost = double.tryParse(value);
                if (cost == null || cost < 0) {
                  return 'Please enter valid cost';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workshop Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _workshopNameController,
              decoration: const InputDecoration(
                labelText: 'Workshop Name',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _serviceProviderController,
              decoration: const InputDecoration(
                labelText: 'Service Provider',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _workshopContactController,
              decoration: const InputDecoration(
                labelText: 'Workshop Contact',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPhotosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Receipt Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_receiptPhotos.length}/5',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos of your service receipts (Max 5 photos)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildPhotoGrid(_receiptPhotos, _addReceiptPhoto),
          ],
        ),
      ),
    );
  }

  Widget _buildServicePhotosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Service Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_servicePhotos.length}/5',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos showing the completed service work (Optional)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildPhotoGrid(_servicePhotos, _addServicePhoto),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(List<File> photos, VoidCallback onAdd) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...photos.map((photo) => _buildPhotoTile(photo, photos)),
        if (photos.length < 5) _buildAddPhotoTile(onAdd),
      ],
    );
  }

  Widget _buildPhotoTile(File photo, List<File> photoList) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              photo,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(photo, photoList),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoTile(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Any additional information about the service...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitService,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Submitting...'),
                ],
              )
            : const Text(
                'Submit for Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _serviceDateController.text = _formatDate(date);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _addReceiptPhoto() async {
    if (_receiptPhotos.length >= 5) return;
    await _addPhoto(_receiptPhotos);
  }

  Future<void> _addServicePhoto() async {
    if (_servicePhotos.length >= 5) return;
    await _addPhoto(_servicePhotos);
  }

  Future<void> _addPhoto(List<File> photoList) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          photoList.add(File(image.path));
        });
      }
    }
  }

  void _removePhoto(File photo, List<File> photoList) {
    setState(() {
      photoList.remove(photo);
    });
  }

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_receiptPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one receipt photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<VehicleProvider>();
      await provider.submitService(
        serviceScheduleId: widget.service.id!,
        serviceDate: _serviceDateController.text,
        odometerReading: int.parse(_odometerController.text),
        cost: double.parse(_costController.text),
        workshopName: _workshopNameController.text,
        serviceProvider: _serviceProviderController.text,
        workshopContact: _workshopContactController.text,
        notes: _notesController.text,
        receiptPhotos: _receiptPhotos.map((file) => file.path).toList(),
        servicePhotos: _servicePhotos.map((file) => file.path).toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service submitted successfully! Awaiting admin review.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _serviceDateController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _workshopNameController.dispose();
    _serviceProviderController.dispose();
    _workshopContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}