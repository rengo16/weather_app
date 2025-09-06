import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/datasources/api_service.dart';
import 'data/repos/weather_repo_impl.dart';
import 'domain/usecases/get_weather_by_city.dart';
import 'presentation/providers/weather_notifier.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final weatherRepositoryProvider = Provider((ref) => WeatherRepositoryImpl(ref.read(apiServiceProvider)));
final getWeatherUseCaseProvider = Provider((ref) => GetWeatherByCity(ref.read(weatherRepositoryProvider)));
final weatherNotifierProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref.read(getWeatherUseCaseProvider));
});
