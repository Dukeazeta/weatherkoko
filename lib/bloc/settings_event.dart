abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ToggleTemperatureUnit extends SettingsEvent {
  final bool useFahrenheit;
  ToggleTemperatureUnit({required this.useFahrenheit});
}
