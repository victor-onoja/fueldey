import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/app_theme_colors.dart';
import '../../auth/auth_bloc.dart';
import '../fuel_station/fuel_station_model.dart';
import 'map_screen_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    // Load nearest fuel stations when screen initializes
    context.read<MapScreenBloc>().add(LoadNearestFuelStations());
  }

// add listener on signout return back to auth screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Finder'),
        actions: [
          // Toggle view mode button
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              context.read<MapScreenBloc>().add(ToggleViewMode());
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOut());
            },
          ),
        ],
      ),
      body: BlocBuilder<MapScreenBloc, MapScreenState>(
        builder: (context, state) {
          if (state is MapScreenLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapScreenError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (state is MapScreenLoaded) {
            return state.viewMode == ViewMode.map
                ? _buildMapView(state)
                : _buildListView(state);
          }

          return const Center(child: Text('No fuel stations found'));
        },
      ),
      // test update current location
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<MapScreenBloc>().add(UpdateCurrentLocation());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildMapView(MapScreenLoaded state) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
            state.currentPosition.latitude, state.currentPosition.longitude),
        zoom: 14,
      ),
      markers: _buildMarkers(state.fuelStations),
      polylines: state.routePolylines.isNotEmpty
          ? {
              Polyline(
                polylineId: const PolylineId('route'),
                points: state.routePolylines,
                color: AppColors.primary,
                width: 5,
              )
            }
          : {},
      myLocationEnabled: true,
      compassEnabled: true,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  Widget _buildListView(MapScreenLoaded state) {
    return ListView.builder(
      itemCount: state.fuelStations.length,
      itemBuilder: (context, index) {
        final station = state.fuelStations[index];
        return _buildFuelStationCard(station);
      },
    );
  }

  Widget _buildFuelStationCard(FuelStation station) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(station.name),
        subtitle: Text(station.address),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (station.hasFuel)
              const Text('Fuel', style: TextStyle(fontSize: 12)),
          ],
        ),
        onTap: () {
          // Calculate route to selected station
          context.read<MapScreenBloc>().add(CalculateRouteToStation(station));
        },
      ),
    );
  }

  Set<Marker> _buildMarkers(List<FuelStation> stations) {
    return stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.location.latitude, station.location.longitude),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: station.address,
          onTap: () {
            // Calculate route to tapped station
            context.read<MapScreenBloc>().add(CalculateRouteToStation(station));
          },
        ),
        icon: station.hasFuel
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarker,
      );
    }).toSet();
  }
}
