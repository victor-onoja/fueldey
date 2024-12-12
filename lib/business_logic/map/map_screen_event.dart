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
