import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../fuel_station/fuel_station_model.dart';
import '../fuel_station/fuel_station_repository.dart';
import '../../utils/location_service.dart';

part 'map_screen_event.dart';
part 'map_screen_state.dart';

class MapScreenBloc extends Bloc<MapScreenEvent, MapScreenState> {
  final LocationService _locationService;
  final FuelStationRepository _fuelStationRepository;
  PolylinePoints polylinePoints = PolylinePoints();

  MapScreenBloc({
    required LocationService locationService,
    required FuelStationRepository fuelStationRepository,
  })  : _locationService = locationService,
        _fuelStationRepository = fuelStationRepository,
        super(MapScreenInitial()) {
    on<LoadNearestFuelStations>(_onLoadNearestFuelStations);
    on<UpdateCurrentLocation>(_onUpdateCurrentLocation);
    on<CalculateRouteToStation>(_onCalculateRouteToStation);
    on<ToggleViewMode>(_onToggleViewMode);
  }

  Future<void> _onLoadNearestFuelStations(
      LoadNearestFuelStations event, Emitter<MapScreenState> emit) async {
    try {
      emit(MapScreenLoading());

      // Get current location
      final Position currentPosition =
          await _locationService.getCurrentLocation();

      // Fetch nearest fuel stations
      final stations =
          await _fuelStationRepository.getNearestFuelStations(currentPosition);

      emit(MapScreenLoaded(
        currentPosition: currentPosition,
        fuelStations: stations,
        viewMode: ViewMode.map,
      ));
    } catch (error) {
      emit(MapScreenError(error.toString()));
    }
  }

  Future<void> _onUpdateCurrentLocation(
      UpdateCurrentLocation event, Emitter<MapScreenState> emit) async {
    try {
      final Position currentPosition =
          await _locationService.getCurrentLocation();

      if (state is MapScreenLoaded) {
        final currentState = state as MapScreenLoaded;
        emit(currentState.copyWith(currentPosition: currentPosition));
      }

      print('Updated current location: $currentPosition');
    } catch (error) {
      emit(MapScreenError(error.toString()));
    }
  }

  Future<void> _onCalculateRouteToStation(
      CalculateRouteToStation event, Emitter<MapScreenState> emit) async {
    try {
      if (state is! MapScreenLoaded) return;

      final currentState = state as MapScreenLoaded;
      final currentPosition = currentState.currentPosition;
      final selectedStation = event.station;

      // Calculate route using Google Maps API or similar service
      // This is a placeholder - you'd integrate with a routing service

      final PolylineResult result = await polylinePoints
          .getRouteBetweenCoordinates(
              request: PolylineRequest(
                  origin: PointLatLng(
                      currentPosition.latitude, currentPosition.longitude),
                  destination: PointLatLng(selectedStation.location.latitude,
                      selectedStation.location.longitude),
                  mode: TravelMode.walking),
              googleApiKey: 'AIzaSyABZAm1m2YV1GnTiYsPosY_cHxiXf9jqHY');
      // googleApiKey: 'AIzaSyAGRzqOnwe8m-t0VKcVoY3__DkLFay0sbw');

      // Convert polyline points to Google Maps Polyline
      if (result.status == 'OK') {
        final List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        emit(currentState.copyWith(
          selectedStation: selectedStation,
          routePolylines: polylineCoordinates,
        ));
      } else {
        emit(MapScreenError('Failed to calculate route: ${result.status}'));
      }
    } catch (error) {
      emit(MapScreenError(error.toString()));
      print('Failed to calculate route: $error');
    }
  }

  void _onToggleViewMode(ToggleViewMode event, Emitter<MapScreenState> emit) {
    if (state is MapScreenLoaded) {
      final currentState = state as MapScreenLoaded;
      emit(currentState.copyWith(
          viewMode: currentState.viewMode == ViewMode.map
              ? ViewMode.list
              : ViewMode.map));
    }
  }
}
