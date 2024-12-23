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
    final position = await getCurrentLocation();
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchDailyForecast() async {
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
          final DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
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
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Failed to fetch forecast data: $e');
    }
  }
}

class HourlyForecast {
  final DateTime date;
  final double temperature;
  final String description;
  final String icon;

  HourlyForecast({required this.date, required this.temperature, required this.description, required this.icon});
}
