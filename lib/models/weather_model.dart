import 'package:equatable/equatable.dart';

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
        visibility
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
}
