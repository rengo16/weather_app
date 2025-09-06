import '../entities/weather.dart';
import '../repos/weather_repo.dart';

class GetWeatherByCity {
  final IWeatherRepository repository;
  GetWeatherByCity(this.repository);

  Future<Weather> call(String city, {required bool useCelsius}) {
    return repository.getWeatherByCity(city, useCelsius: useCelsius);
  }
}
