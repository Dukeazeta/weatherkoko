import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherkoko/models/weather_model.dart';
import '../services/weather_service.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _weatherService;

  WeatherBloc(this._weatherService) : super(WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
  }

  String _getWeatherAnimation(String weatherDescription) {
    weatherDescription = weatherDescription.toLowerCase();
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 18;

    if (weatherDescription.contains('cloud') ||
        weatherDescription.contains('overcast')) {
      return isNight ? 'assets/Cloudy night.json' : 'assets/Cloudy.json';
    } else if (weatherDescription.contains('clear') ||
        weatherDescription.contains('sunny')) {
      return isNight ? 'assets/Clear night.json' : 'assets/Sunny.json';
    } else if (weatherDescription.contains('rain') ||
        weatherDescription.contains('drizzle')) {
      return 'assets/Light Rain.json';
    } else if (weatherDescription.contains('thunder') ||
        weatherDescription.contains('storm')) {
      return 'assets/Thunderstorm.json';
    } else if (weatherDescription.contains('snow') ||
        weatherDescription.contains('sleet')) {
      return isNight ? 'assets/Snowy night.json' : 'assets/Snowy.json';
    } else if (weatherDescription.contains('mist') ||
        weatherDescription.contains('fog') ||
        weatherDescription.contains('haze')) {
      return 'assets/Foggy.json';
    } else if (weatherDescription.contains('wind')) {
      return 'assets/Windy.json';
    } else if (weatherDescription.contains('partly')) {
      return 'assets/Partly Cloudy.json';
    }

    return isNight ? 'assets/Clear night.json' : 'assets/Sunny.json';
  }

  Future<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    try {
      final weatherData = await _weatherService.fetchWeatherByLocation();
      final animation = _getWeatherAnimation(
        weatherData["weather"][0]["description"].toString(),
      );
      emit(WeatherLoaded(WeatherModel.fromJson(weatherData, animation)));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is WeatherLoaded) {
      try {
        final weatherData = await _weatherService.fetchWeatherByLocation();
        final animation = _getWeatherAnimation(
          weatherData["weather"][0]["description"].toString(),
        );
        emit(WeatherLoaded(WeatherModel.fromJson(weatherData, animation)));
      } catch (e) {
        emit(WeatherError(e.toString()));
      }
    }
  }
}
