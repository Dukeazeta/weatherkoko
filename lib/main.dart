import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/weather_service.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  String weather = "Loading...";
  double temperature = 0;
  String location = "";
  bool isLoading = false;
  String currentAnimation = '';

  String _getWeatherAnimation(String weatherDescription) {
    weatherDescription = weatherDescription.toLowerCase();
    if (weatherDescription.contains('cloud') ||
        weatherDescription.contains('overcast')) {
      return 'assets/Cloudy.json';
    } else if (weatherDescription.contains('clear') ||
        weatherDescription.contains('sunny')) {
      return 'assets/Sunny.json';
    }
    return '';
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });

    try {
      final weatherData = await _weatherService.fetchWeatherByLocation();
      final weatherDescription =
          weatherData["weather"][0]["description"].toString();

      setState(() {
        weather = weatherDescription[0].toUpperCase() +
            weatherDescription.substring(1);
        temperature = weatherData["main"]["temp"].toDouble();
        location = weatherData["name"];
        currentAnimation =
            _getWeatherAnimation(weatherDescription.toLowerCase());
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        weather = "Error: ${e.toString()}";
        currentAnimation = '';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    Timer.periodic(Duration(minutes: 10), (timer) => _fetchWeather());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Text(
                    location,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (currentAnimation.isNotEmpty)
                    Lottie.asset(
                      currentAnimation,
                      width: 200,
                      height: 200,
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          temperature.toStringAsFixed(1),
                          textScaleFactor: 1.2,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 96,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -4,
                          ),
                        ),
                        Text(
                          toBeginningOfSentenceCase(weather) ?? weather,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
