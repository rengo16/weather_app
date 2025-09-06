import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/weather_model.dart';

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final http.Client client = http.Client();

  
  
  
  Future<WeatherModel> fetchWeatherByCity(String city, {required bool useCelsius}) async {
    final units = useCelsius ? 'metric' : 'imperial';
    final url = Uri.parse('${AppConstants.baseUrl}?q=${Uri.encodeComponent(city)}&appid=${AppConstants.apiKey}&units=$units');

    
    print('📡 ApiService: GET $url');

    final response = await client.get(url);

    print('📥 ApiService: status=${response.statusCode} body=${response.body}');

    final decoded = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(decoded);
    } else {
      
      final message = decoded['message'] ?? decoded['error'] ?? response.body;
      throw Exception('API Error ${response.statusCode}: $message');
    }
  }
}
