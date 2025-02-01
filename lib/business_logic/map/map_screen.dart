import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fueldey/auth/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../auth/logic/auth_event.dart';
import '../../auth/logic/auth_state.dart';
import '../../auth/logic/user_model.dart';
import '../../utils/app_theme_colors.dart';
import '../../auth/logic/auth_bloc.dart';
import '../fuel_station/fuel_station_model.dart';
import 'map_screen_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  void _handleProfileNavigation() {
    context.push('/profile');
  }

  void _handleAdminNavigation() {
    context.push('/admin');
  }

  void _handleStationManagement() {
    context.push('/station-management');
  }

  GoogleMapController? _mapController;
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load nearest fuel stations when screen initializes
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.role == UserRole.moderator) {
      // Load only the moderator's station
      context.read<MapScreenBloc>().add(
            LoadModeratorStation(stationName: authState.user!.stationName!),
          );
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
    final userRole = authState.user?.role ?? UserRole.regular;
    final isAdmin = userRole == UserRole.admin;
    final isModerator = userRole == UserRole.moderator;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isModerator
              ? 'Station Management - ${authState.user?.stationName}'
              : isAdmin
                  ? 'Admin Dashboard'
                  : 'Fuel Finder'),
          actions: [
            _buildActionButtons(isAdmin, isModerator),
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
                  ? _buildModeratorView(state)
                  : isAdmin
                      ? _buildAdminView(state)
                      : state.viewMode == ViewMode.map
                          ? _buildMapView(state)
                          : _buildListView(state);
            }

            return const Center(child: Text('No fuel stations found'));
          },
        ),
        floatingActionButton: !isModerator && !isAdmin
            ? null
            // FloatingActionButton(
            //     onPressed: () {
            //       context.read<MapScreenBloc>().add(UpdateCurrentLocation());
            //     },
            //     backgroundColor: AppColors.primary,
            //     child: const Icon(Icons.my_location),
            //   )
            : null,
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

  Widget _buildAdminView(MapScreenLoaded state) {
    // Add admin dashboard UI here
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
                    'Admin Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  // Add admin functionality here
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to user management screen
                    },
                    child: const Text('Manage Users'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to station management screen
                    },
                    child: const Text('Manage Stations'),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildModeratorView(MapScreenLoaded state) {
    // Remove moderatorName parameter as it should come from AuthState
    final authState = context.read<AuthBloc>().state;
    final moderatorName = authState.user?.name ?? 'Unknown';

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

  Widget _buildActionButtons(bool isAdmin, bool isModerator) {
    return Row(
      children: [
        if (!isModerator && !isAdmin)
          BlocBuilder<MapScreenBloc, MapScreenState>(
            builder: (context, state) {
              if (state is MapScreenLoaded) {
                return IconButton(
                  icon: Icon(state.viewMode == ViewMode.map
                      ? Icons.view_list
                      : Icons.map),
                  onPressed: () =>
                      context.read<MapScreenBloc>().add(ToggleViewMode()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: _handleAdminNavigation,
          ),
        if (isModerator)
          IconButton(
            icon: const Icon(Icons.edit_location),
            onPressed: _handleStationManagement,
          ),
        _buildUserMenu(),
      ],
    );
  }

  Widget _buildUserMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'logout':
            context.read<AuthBloc>().add(AuthSignOut());
            break;
          case 'profile':
            _handleProfileNavigation();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Text('Profile'),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
    );
  }
}
