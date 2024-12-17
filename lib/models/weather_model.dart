import 'package:equatable/equatable.dart';

class WeatherModel extends Equatable {
  final String description;
  final double temperature;
  final String location;
  final String animation;

  const WeatherModel({
    required this.description,
    required this.temperature,
    required this.location,
    required this.animation,
  });

  @override
  List<Object?> get props => [description, temperature, location, animation];

  factory WeatherModel.fromJson(Map<String, dynamic> json, String animationPath) {
    final weatherDescription = json["weather"][0]["description"].toString();
    return WeatherModel(
      description: weatherDescription[0].toUpperCase() + weatherDescription.substring(1),
      temperature: json["main"]["temp"].toDouble(),
      location: json["name"],
      animation: animationPath,
    );
  }
}
