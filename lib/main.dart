import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'services/weather_service.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bloc/weather_bloc.dart';
import 'bloc/weather_event.dart';
import 'bloc/weather_state.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'screens/detailed_weather_screen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  @override
  void initState() {
    super.initState();
    _recordAppVisit();
  }

  Future<void> _recordAppVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setBool('visit_$today', true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              WeatherBloc(WeatherService())..add(FetchWeather()),
        ),
        BlocProvider(
          create: (context) => SettingsBloc()..add(LoadSettings()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WeatherKoko',
          theme: themeProvider.theme,
          home: WeatherScreen(),
        ),
      ),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  double _convertTemperature(double celsius, bool toFahrenheit) {
    if (toFahrenheit) {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  String _formatTemperature(double temperature, bool useFahrenheit) {
    final convertedTemp = _convertTemperature(temperature, useFahrenheit);
    return '${convertedTemp.round()}°${useFahrenheit ? 'F' : 'C'}';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WeatherBloc>().add(FetchWeather());
        await Future.delayed(Duration(seconds: 1));
      },
      child: Scaffold(
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
              return BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
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
                                      builder: (context) => BlocProvider.value(
                                        value: BlocProvider.of<SettingsBloc>(
                                            context),
                                        child: DetailedWeatherScreen(
                                          weather: state.weather,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  _formatTemperature(state.weather.temperature,
                                      settingsState.useFahrenheit),
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
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
