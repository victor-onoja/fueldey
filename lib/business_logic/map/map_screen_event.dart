part of 'map_screen_bloc.dart';

abstract class MapScreenEvent extends Equatable {
  const MapScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadNearestFuelStations extends MapScreenEvent {}

class UpdateCurrentLocation extends MapScreenEvent {}

class CalculateRouteToStation extends MapScreenEvent {
  final FuelStation station;

  const CalculateRouteToStation(this.station);

  @override
  List<Object> get props => [station];
}

class ToggleViewMode extends MapScreenEvent {}

class LoadModeratorStation extends MapScreenEvent {
  final String stationName;

  const LoadModeratorStation({required this.stationName});

  @override
  List<Object> get props => [stationName];
}

class UpdateStationStatus extends MapScreenEvent {
  final String stationId;
  final Map<String, dynamic> updates;
  final String moderatorName;

  const UpdateStationStatus({
    required this.stationId,
    required this.updates,
    required this.moderatorName,
  });

  @override
  List<Object> get props => [stationId, updates, moderatorName];
}
