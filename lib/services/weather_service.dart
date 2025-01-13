import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  final String apiKey = '42f1f12dc0b39d4ca8f0bdc611f78d1f';

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> fetchWeatherByLocation() async {
    try {
      final position = await getCurrentLocation();
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 401) {
          throw Exception(
              'Invalid API key. Please check your OpenWeather API key.');
        } else if (response.statusCode == 429) {
          throw Exception('API rate limit exceeded. Please try again later.');
        } else {
          throw Exception(
              'Weather API error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        if (e.toString().contains('SocketException')) {
          throw Exception(
              'Network error. Please check your internet connection.');
        }
        throw Exception('Failed to fetch weather data: $e');
      }
    } catch (e) {
      if (e.toString().contains('Location services are disabled')) {
        throw Exception('Please enable location services to get weather data.');
      } else if (e.toString().contains('Location permissions are denied')) {
        throw Exception(
            'Please grant location permissions to get weather data.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchDailyForecast() async {
    try {
      final position = await getCurrentLocation();
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Process hourly forecast data
          final List<dynamic> hourlyList = data['list'];
          final List<HourlyForecast> hourlyForecasts = [];

          // Get next 24 hours of forecast (8 data points, as each is 3 hours apart)
          for (var i = 0; i < 8 && i < hourlyList.length; i++) {
            final item = hourlyList[i];
            final DateTime date =
                DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
            hourlyForecasts.add(
              HourlyForecast(
                date: date,
                temperature: item['main']['temp'].toDouble(),
                description: item['weather'][0]['description'],
                icon: item['weather'][0]['icon'],
              ),
            );
          }

          data['hourly_forecast'] = hourlyForecasts;
          return data;
        } else if (response.statusCode == 401) {
          throw Exception(
              'Invalid API key. Please check your OpenWeather API key.');
        } else if (response.statusCode == 429) {
          throw Exception('API rate limit exceeded. Please try again later.');
        } else {
          throw Exception(
              'Weather API error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        if (e.toString().contains('SocketException')) {
          throw Exception(
              'Network error. Please check your internet connection.');
        }
        throw Exception('Failed to fetch forecast data: $e');
      }
    } catch (e) {
      if (e.toString().contains('Location services are disabled')) {
        throw Exception('Please enable location services to get weather data.');
      } else if (e.toString().contains('Location permissions are denied')) {
        throw Exception(
            'Please grant location permissions to get weather data.');
      }
      rethrow;
    }
  }
}

class HourlyForecast {
  final DateTime date;
  final double temperature;
  final String description;
  final String icon;

  HourlyForecast(
      {required this.date,
      required this.temperature,
      required this.description,
      required this.icon});
}
