part of 'map_screen_bloc.dart';

enum ViewMode { map, list }

abstract class MapScreenState extends Equatable {
  const MapScreenState();

  @override
  List<Object?> get props => [];
}

class MapScreenInitial extends MapScreenState {}

class MapScreenLoading extends MapScreenState {}

class MapScreenError extends MapScreenState {
  final String message;

  const MapScreenError(this.message);

  @override
  List<Object> get props => [message];
}

class MapScreenLoaded extends MapScreenState {
  final Position currentPosition;
  final List<FuelStation> fuelStations;
  final FuelStation? selectedStation;
  final List<LatLng> routePolylines;
  final ViewMode viewMode;

  const MapScreenLoaded({
    required this.currentPosition,
    required this.fuelStations,
    this.selectedStation,
    this.routePolylines = const [],
    this.viewMode = ViewMode.map,
  });

  MapScreenLoaded copyWith({
    Position? currentPosition,
    List<FuelStation>? fuelStations,
    FuelStation? selectedStation,
    List<LatLng>? routePolylines,
    ViewMode? viewMode,
  }) {
    return MapScreenLoaded(
      currentPosition: currentPosition ?? this.currentPosition,
      fuelStations: fuelStations ?? this.fuelStations,
      selectedStation: selectedStation ?? this.selectedStation,
      routePolylines: routePolylines ?? this.routePolylines,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [
        currentPosition,
        fuelStations,
        selectedStation,
        routePolylines,
        viewMode
      ];
}
