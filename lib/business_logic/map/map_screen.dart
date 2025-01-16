import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../auth/auth_screen.dart';
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
  GoogleMapController? _mapController;
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load nearest fuel stations when screen initializes
    final authState = context.read<AuthBloc>().state;
    if (authState.isModerator && authState.stationName != null) {
      // Load only the moderator's station
      context
          .read<MapScreenBloc>()
          .add(LoadModeratorStation(stationName: authState.stationName!));
    } else {
      // Load all nearby stations for regular users
      context.read<MapScreenBloc>().add(LoadNearestFuelStations());
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isModerator = authState.isModerator;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isModerator
              ? 'Station Management - ${authState.stationName}'
              : 'Fuel Finder'),
          actions: [
            if (!isModerator)
              BlocBuilder<MapScreenBloc, MapScreenState>(
                builder: (context, state) {
                  if (state is MapScreenLoaded) {
                    return IconButton(
                      icon: Icon(state.viewMode == ViewMode.map
                          ? Icons.view_list
                          : Icons.map),
                      onPressed: () {
                        context.read<MapScreenBloc>().add(ToggleViewMode());
                      },
                    );
                  }
                  return const SizedBox.shrink();
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
              return isModerator
                  ? _buildModeratorView(state, authState.moderatorName!)
                  : state.viewMode == ViewMode.map
                      ? _buildMapView(state)
                      : _buildListView(state);
            }

            return const Center(child: Text('No fuel stations found'));
          },
        ),
        // test update current location
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     context.read<MapScreenBloc>().add(UpdateCurrentLocation());
        //   },
        //   backgroundColor: AppColors.primary,
        //   child: const Icon(Icons.my_location),
        // ),
      ),
    );
  }

  Widget _buildMapView(MapScreenLoaded state) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
            state.currentPosition.latitude, state.currentPosition.longitude),
        zoom: 16,
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
        setState(() {
          _mapController = controller;
        });
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(station.address),
            const SizedBox(height: 4),
            Text('Price: ₦${station.fuelPrice}'),
            Text(
              'Last Updated: ${DateFormat('MMM d, y h:mm a').format(station.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            station.hasFuel
                ? const Text('Fuel here', style: TextStyle(fontSize: 12))
                : const Text('No Fuel', style: TextStyle(fontSize: 12)),
          ],
        ),
        onTap: () {
          print('Tapped station: ${station.name}');
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
            print('Tapped station: ${station.name}');
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

  Widget _buildModeratorView(MapScreenLoaded state, String moderatorName) {
    if (state.fuelStations.isEmpty) {
      return const Center(child: Text('Station not found'));
    }

    final station = state.fuelStations.first;

    print('Station: ${station.fuelPrice}');

    _priceController.text = station.fuelPrice.toString();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Station Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text('Name: ${station.name}'),
                  Text('Address: ${station.address}'),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Has Fuel'),
                    value: station.hasFuel,
                    onChanged: (value) {
                      context.read<MapScreenBloc>().add(
                            UpdateStationStatus(
                              stationId: station.id,
                              updates: {'hasFuel': value},
                              moderatorName: moderatorName,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Fuel Price',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final price = double.tryParse(_priceController.text);
                          if (price != null) {
                            context.read<MapScreenBloc>().add(
                                  UpdateStationStatus(
                                    stationId: station.id,
                                    updates: {'fuelPrice': price},
                                    moderatorName: moderatorName,
                                  ),
                                );
                          }
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text('Update Price'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (station.updatedBy != null)
                    Text(
                      'Updated By: ${station.updatedBy}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
