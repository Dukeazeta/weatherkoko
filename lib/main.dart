import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/weather_service.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/weather_bloc.dart';
import 'bloc/weather_event.dart';
import 'bloc/weather_state.dart';
import 'screens/detailed_weather_screen.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => WeatherBloc(WeatherService())..add(FetchWeather()),
        child: WeatherScreen(),
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 17, 20),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WeatherError) {
            return Center(child: Text(state.message));
          }

          if (state is WeatherLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Text(
                    state.weather.location,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Lottie.asset(
                    state.weather.animation,
                    width: 300,
                    height: 300,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailedWeatherScreen(
                                  weather: state.weather,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            state.weather.temperature.toStringAsFixed(1),
                            textScaleFactor: 1.3,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 115,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              letterSpacing: -4,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        Text(
                          toBeginningOfSentenceCase(
                                  state.weather.description) ??
                              state.weather.description,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
