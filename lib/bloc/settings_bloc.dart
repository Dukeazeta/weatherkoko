import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';

// States
class SettingsState {
  final bool useFahrenheit;

  SettingsState({required this.useFahrenheit});
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState(useFahrenheit: false)) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTemperatureUnit>(_onToggleTemperatureUnit);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final useFahrenheit = prefs.getBool('useFahrenheit') ?? false;
    emit(SettingsState(useFahrenheit: useFahrenheit));
  }

  Future<void> _onToggleTemperatureUnit(ToggleTemperatureUnit event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useFahrenheit', event.useFahrenheit);
    emit(SettingsState(useFahrenheit: event.useFahrenheit));
  }
}
