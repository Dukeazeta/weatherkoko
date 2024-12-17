import 'package:equatable/equatable.dart';

class DailyForecast {
  final DateTime date;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;

  DailyForecast({
    required this.date,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
  });

  String get animation {
    final hour = date.hour;
    final isNight = hour < 6 || hour > 18;
    final desc = description.toLowerCase();

    if (desc.contains('cloud') || desc.contains('overcast')) {
      return isNight ? 'assets/Cloudy night.json' : 'assets/Cloudy.json';
    } else if (desc.contains('clear') || desc.contains('sunny')) {
      return isNight ? 'assets/Clear night.json' : 'assets/Sunny.json';
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return 'assets/Light Rain.json';
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      return 'assets/Thunderstorm.json';
    } else if (desc.contains('snow') || desc.contains('sleet')) {
      return isNight ? 'assets/Snowy night.json' : 'assets/Snowy.json';
    } else if (desc.contains('mist') || desc.contains('fog') || desc.contains('haze')) {
      return 'assets/Foggy.json';
    } else if (desc.contains('wind')) {
      return 'assets/Windy.json';
    } else if (desc.contains('partly')) {
      return 'assets/Partly Cloudy.json';
    }

    return isNight ? 'assets/Clear night.json' : 'assets/Sunny.json';
  }
}

class WeatherModel extends Equatable {
  final String description;
  final double temperature;
  final double feelsLike;
  final String location;
  final String animation;
  final double windSpeed;
  final String windDirection;
  final int? pressure;
  final int? humidity;
  final int? uvIndex;
  final double? dewPoint;
  final double? visibility;
  final List<DailyForecast> dailyForecast;

  const WeatherModel({
    required this.description,
    required this.temperature,
    required this.feelsLike,
    required this.location,
    required this.animation,
    required this.windSpeed,
    required this.windDirection,
    this.pressure,
    this.humidity,
    this.uvIndex,
    this.dewPoint,
    this.visibility,
    this.dailyForecast = const [],
  });

  @override
  List<Object?> get props => [
        description,
        temperature,
        feelsLike,
        location,
        animation,
        windSpeed,
        windDirection,
        pressure,
        humidity,
        uvIndex,
        dewPoint,
        visibility,
        dailyForecast,
      ];

  factory WeatherModel.fromJson(Map<String, dynamic> json, String animationPath) {
    final weatherDescription = json["weather"][0]["description"].toString();
    final mainData = json["main"] as Map<String, dynamic>;
    final windData = json["wind"] as Map<String, dynamic>;
    
    return WeatherModel(
      description: weatherDescription[0].toUpperCase() + weatherDescription.substring(1),
      temperature: (mainData["temp"] as num).toDouble(),
      feelsLike: (mainData["feels_like"] as num).toDouble(),
      location: json["name"],
      animation: animationPath,
      windSpeed: (windData["speed"] as num).toDouble(),
      windDirection: windData["deg"].toString(),
      pressure: mainData["pressure"] as int?,
      humidity: mainData["humidity"] as int?,
      uvIndex: json["uvi"] as int?,
      dewPoint: mainData["dew_point"] != null ? (mainData["dew_point"] as num).toDouble() : null,
      visibility: json["visibility"] != null ? (json["visibility"] as num).toDouble() : null,
    );
  }

  WeatherModel copyWith({
    String? description,
    double? temperature,
    double? feelsLike,
    String? location,
    String? animation,
    double? windSpeed,
    String? windDirection,
    int? pressure,
    int? humidity,
    int? uvIndex,
    double? dewPoint,
    double? visibility,
    List<DailyForecast>? dailyForecast,
  }) {
    return WeatherModel(
      description: description ?? this.description,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      location: location ?? this.location,
      animation: animation ?? this.animation,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      pressure: pressure ?? this.pressure,
      humidity: humidity ?? this.humidity,
      uvIndex: uvIndex ?? this.uvIndex,
      dewPoint: dewPoint ?? this.dewPoint,
      visibility: visibility ?? this.visibility,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }
}
