import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/logic/auth_bloc.dart';
import '../fuel_station/fuel_station_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StationManagementScreen extends StatefulWidget {
  final FuelStation? station;
  final bool isEditing;

  const StationManagementScreen({
    super.key,
    this.station,
    this.isEditing = false,
  });

  @override
  _StationManagementScreenState createState() =>
      _StationManagementScreenState();
}

class _StationManagementScreenState extends State<StationManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  LatLng? _selectedLocation;
  bool _hasFuel = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.station?.name);
    _addressController = TextEditingController(text: widget.station?.address);
    _priceController = TextEditingController(
        text: widget.station?.fuelPrice.toString() ?? '0.0');
    if (widget.station != null) {
      _selectedLocation = LatLng(
        widget.station!.location.latitude,
        widget.station!.location.longitude,
      );
      _hasFuel = widget.station!.hasFuel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Station' : 'Add Station'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Station Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter station name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter station address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Fuel Price',
                  border: OutlineInputBorder(),
                  prefixText: '₦',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fuel price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Has Fuel'),
                value: _hasFuel,
                onChanged: (bool value) {
                  setState(() {
                    _hasFuel = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _buildMap(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSubmit,
                child:
                    Text(widget.isEditing ? 'Update Station' : 'Add Station'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _selectedLocation ??
            const LatLng(9.0820, 8.6753), // Default to center of Nigeria
        zoom: 15,
      ),
      markers: _selectedLocation != null
          ? {
              Marker(
                markerId: const MarkerId('station'),
                position: _selectedLocation!,
              ),
            }
          : {},
      onTap: (LatLng location) {
        setState(() {
          _selectedLocation = location;
        });
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      // Create or update station logic here
      final station = FuelStation(
        id: widget.station?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        address: _addressController.text,
        location: _selectedLocation!,
        fuelPrice: double.parse(_priceController.text),
        hasFuel: _hasFuel,
        lastUpdated: DateTime.now(),
        updatedBy: context.read<AuthBloc>().state.user?.username,
      );

      // Add your station update/create logic here

      Navigator.pop(context);
    } else if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
        ),
      );
    }
  }
}
