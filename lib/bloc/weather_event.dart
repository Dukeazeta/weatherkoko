import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class FetchWeather extends WeatherEvent {}

class RefreshWeather extends WeatherEvent {}

class WeatherRequested extends WeatherEvent {
  final String city;

  const WeatherRequested(this.city);

  @override
  List<Object?> get props => [city];
}
