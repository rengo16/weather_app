import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  WeatherModel({
    required String city,
    required double temperature,
    required String condition,
    required String description,
    required String iconCode,
  }) : super(
    city: city,
    temperature: temperature,
    condition: condition,
    description: description,
    iconCode: iconCode,
  );

  
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final city = json['name'] as String? ?? '';
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final w = weatherList.isNotEmpty ? weatherList[0] as Map<String, dynamic> : <String, dynamic>{};

    final tempNum = main['temp'];
    final temperature = tempNum is num ? tempNum.toDouble() : double.tryParse('$tempNum') ?? 0.0;
    final condition = (w['main'] as String?) ?? 'Unknown';
    final description = (w['description'] as String?) ?? '';
    final iconCode = (w['icon'] as String?) ?? '';

    return WeatherModel(
      city: city,
      temperature: temperature,
      condition: condition,
      description: description,
      iconCode: iconCode,
    );
  }
}
