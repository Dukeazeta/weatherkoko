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
      final forecastData = await _weatherService.fetchDailyForecast();

      // Group forecast data by day
      final Map<String, List<dynamic>> groupedForecasts = {};
      for (var item in forecastData['list']) {
        final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final dateKey = '${date.year}-${date.month}-${date.day}';
        if (!groupedForecasts.containsKey(dateKey)) {
          groupedForecasts[dateKey] = [];
        }
        groupedForecasts[dateKey]!.add(item);
      }

      // Create daily forecasts using mid-day temperature (around 12:00)
      final dailyForecasts = groupedForecasts.entries.map((entry) {
        final forecasts = entry.value;
        // Find forecast closest to 12:00
        final middayForecast = forecasts.reduce((a, b) {
          final timeA = DateTime.fromMillisecondsSinceEpoch(a['dt'] * 1000);
          final timeB = DateTime.fromMillisecondsSinceEpoch(b['dt'] * 1000);
          final diffA = (timeA.hour - 12).abs();
          final diffB = (timeB.hour - 12).abs();
          return diffA < diffB ? a : b;
        });

        return DailyForecast(
          date:
              DateTime.fromMillisecondsSinceEpoch(middayForecast['dt'] * 1000),
          temperature: middayForecast['main']['temp'].toDouble(),
          minTemp: middayForecast['main']['temp_min'].toDouble(),
          maxTemp: middayForecast['main']['temp_max'].toDouble(),
          description: middayForecast['weather'][0]['description'],
          icon: middayForecast['weather'][0]['icon'],
        );
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date)); // Sort by date

      // Remove today's forecast if it exists
      final today = DateTime.now();
      dailyForecasts.removeWhere((forecast) =>
          forecast.date.year == today.year &&
          forecast.date.month == today.month &&
          forecast.date.day == today.day);

      final animation = _getWeatherAnimation(
        weatherData["weather"][0]["description"].toString(),
      );
      final weather = WeatherModel.fromJson(
        weatherData,
        animation,
      ).copyWith(dailyForecast: dailyForecasts);

      emit(WeatherLoaded(weather));
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
        final forecastData = await _weatherService.fetchDailyForecast();

        // Group forecast data by day
        final Map<String, List<dynamic>> groupedForecasts = {};
        for (var item in forecastData['list']) {
          final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateKey = '${date.year}-${date.month}-${date.day}';
          if (!groupedForecasts.containsKey(dateKey)) {
            groupedForecasts[dateKey] = [];
          }
          groupedForecasts[dateKey]!.add(item);
        }

        // Create daily forecasts using mid-day temperature (around 12:00)
        final dailyForecasts = groupedForecasts.entries.map((entry) {
          final forecasts = entry.value;
          // Find forecast closest to 12:00
          final middayForecast = forecasts.reduce((a, b) {
            final timeA = DateTime.fromMillisecondsSinceEpoch(a['dt'] * 1000);
            final timeB = DateTime.fromMillisecondsSinceEpoch(b['dt'] * 1000);
            final diffA = (timeA.hour - 12).abs();
            final diffB = (timeB.hour - 12).abs();
            return diffA < diffB ? a : b;
          });

          return DailyForecast(
            date: DateTime.fromMillisecondsSinceEpoch(
                middayForecast['dt'] * 1000),
            temperature: middayForecast['main']['temp'].toDouble(),
            minTemp: middayForecast['main']['temp_min'].toDouble(),
            maxTemp: middayForecast['main']['temp_max'].toDouble(),
            description: middayForecast['weather'][0]['description'],
            icon: middayForecast['weather'][0]['icon'],
          );
        }).toList()
          ..sort((a, b) => a.date.compareTo(b.date)); // Sort by date

        // Remove today's forecast if it exists
        final today = DateTime.now();
        dailyForecasts.removeWhere((forecast) =>
            forecast.date.year == today.year &&
            forecast.date.month == today.month &&
            forecast.date.day == today.day);

        final animation = _getWeatherAnimation(
          weatherData["weather"][0]["description"].toString(),
        );
        final weather = WeatherModel.fromJson(
          weatherData,
          animation,
        ).copyWith(dailyForecast: dailyForecasts);

        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError(e.toString()));
      }
    }
  }
}
