import '../../domain/entities/weather.dart';
import '../../domain/repos/weather_repo.dart';
import '../datasources/api_service.dart';

class WeatherRepositoryImpl implements IWeatherRepository {
  final ApiService apiService;
  WeatherRepositoryImpl(this.apiService);

  @override
  Future<Weather> getWeatherByCity(String city, {required bool useCelsius}) {
    return apiService.fetchWeatherByCity(city, useCelsius: useCelsius);
  }
}
