import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  final Uri _githubUrl = Uri.parse('https://github.com/Dukeazeta/weatherkoko');

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _toggleTemperatureUnit(bool value) async {
    context
        .read<SettingsBloc>()
        .add(ToggleTemperatureUnit(useFahrenheit: value));
    // Trigger a weather refresh to update all temperatures
    context.read<WeatherBloc>().add(RefreshWeather());
  }

  Future<void> _launchGitHub() async {
    if (!await launchUrl(_githubUrl)) {
      throw Exception('Could not launch $_githubUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<SettingsBloc>(context),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF1B1D1F),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Settings',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  color: const Color(0xFF2C2F33),
                  child: SwitchListTile(
                    title: Text(
                      'Use Fahrenheit',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Switch between Celsius and Fahrenheit',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white70),
                    ),
                    value: state.useFahrenheit,
                    onChanged: _toggleTemperatureUnit,
                    activeColor: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFF2C2F33),
                  child: ListTile(
                    title: Text(
                      'Source Code',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white),
                    ),
                    subtitle: Text(
                      'View project on GitHub',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.code, color: Colors.white),
                    onTap: _launchGitHub,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
