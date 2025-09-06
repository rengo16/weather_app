import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/weather.dart';
import '../../domain/usecases/get_weather_by_city.dart';
import '../../core/constants.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherState {
  final WeatherStatus status;
  final Weather? weather;
  final String? message;
  final bool useCelsius;
  final String lastCity;

  WeatherState({
    required this.status,
    this.weather,
    this.message,
    required this.useCelsius,
    required this.lastCity,
  });

  factory WeatherState.initial() => WeatherState(
    status: WeatherStatus.initial,
    weather: null,
    message: null,
    useCelsius: true,
    lastCity: '',
  );

  WeatherState copyWith({
    WeatherStatus? status,
    Weather? weather,
    String? message,
    bool? useCelsius,
    String? lastCity,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      message: message,
      useCelsius: useCelsius ?? this.useCelsius,
      lastCity: lastCity ?? this.lastCity,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final GetWeatherByCity getWeatherByCity;

  WeatherNotifier(this.getWeatherByCity) : super(WeatherState.initial()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(AppConstants.spLastCity) ?? '';
    final useC = prefs.getBool(AppConstants.spUseCelsius) ?? true;
    state = state.copyWith(useCelsius: useC, lastCity: last);
    if (last.isNotEmpty) {
      
      fetch(last);
    }
  }

  Future<void> toggleUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final newUseC = !state.useCelsius;
    await prefs.setBool(AppConstants.spUseCelsius, newUseC);
    state = state.copyWith(useCelsius: newUseC);
    
    if (state.lastCity.isNotEmpty) {
      await fetch(state.lastCity);
    }
  }

  Future<void> fetch(String city) async {
    if (city.trim().isEmpty) {
      state = state.copyWith(status: WeatherStatus.error, message: 'Please enter a city name');
      return;
    }

    state = state.copyWith(status: WeatherStatus.loading, message: null);
    try {
      final weather = await getWeatherByCity(city, useCelsius: state.useCelsius);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.spLastCity, city);

      state = state.copyWith(
        status: WeatherStatus.success,
        weather: weather,
        message: null,
        lastCity: city,
      );
    } catch (e) {
      state = state.copyWith(status: WeatherStatus.error, message: e.toString());
    }
  }

  Future<void> refresh() async {
    if (state.lastCity.isNotEmpty) {
      await fetch(state.lastCity);
    }
  }
}
