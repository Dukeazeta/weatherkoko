import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color.fromARGB(255, 17, 17, 20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather.location,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildWeatherInfo(),
            const SizedBox(height: 30),
            _buildDetailedInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Row(
      children: [
        Text(
          '${weather.temperature.toStringAsFixed(1)}°C',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feels like ${weather.feelsLike.toStringAsFixed(1)}°C',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              Text(
                weather.description,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Wind',
          '${weather.windSpeed} m/s ${weather.windDirection}',
          Icons.air,
        ),
        _buildInfoRow(
          'Pressure',
          '${weather.pressure ?? 'N/A'} hPa',
          Icons.compress,
        ),
        _buildInfoRow(
          'Humidity',
          '${weather.humidity ?? 'N/A'}%',
          Icons.water_drop,
        ),
        _buildInfoRow(
          'UV Index',
          '${weather.uvIndex ?? 'N/A'}',
          Icons.wb_sunny,
        ),
        _buildInfoRow(
          'Dew Point',
          '${weather.dewPoint?.toStringAsFixed(1) ?? 'N/A'}°C',
          Icons.opacity,
        ),
        _buildInfoRow(
          'Visibility',
          '${(weather.visibility ?? 0) / 1000} km',
          Icons.visibility,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
