import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/weather_model.dart';

class DetailedWeatherScreen extends StatelessWidget {
  final WeatherModel weather;

  const DetailedWeatherScreen({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTemperatureCard(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildForecastCard(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: _buildHourlyForecast(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: _buildInfoGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                weather.location.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${weather.temperature.round()}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Lottie.asset(
                        weather.animation,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayText(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'TOMORROW';
    }
    
    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return weekdays[date.weekday - 1];
  }

  Widget _buildForecastCard() {
    if (weather.dailyForecast.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: PageView.builder(
          itemCount: weather.dailyForecast.length,
          controller: PageController(viewportFraction: 1.0),
          itemBuilder: (context, index) {
            final forecast = weather.dailyForecast[index];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _getDayText(forecast.date),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${forecast.temperature.round()}°',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Lottie.asset(
                            forecast.animation,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${weather.temperature.round()}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.location.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        weather.description.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.cloud_queue, color: Colors.lightBlue, size: 36),
            ],
          ),
          const Spacer(),
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 68,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '68°',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 32,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '54°',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              'NOW',
              '9',
              '12P',
              '3',
              '6',
              '9',
              '12A',
              '3',
            ]
                .map((time) => Text(
                      time,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AIR QUALITY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'GOOD',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AQI:59',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WANING CRESCENT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.nightlight_round,
                  color: Colors.white,
                  size: 32,
                ),
                Text(
                  '25%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
