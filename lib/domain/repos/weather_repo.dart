import '../entities/weather.dart';

abstract class IWeatherRepository {
  
  
  Future<Weather> getWeatherByCity(String city, {required bool useCelsius});
}
