import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  // Using a free weather API - OpenWeatherMap (free tier: 1000 calls/day)
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY'; // You need to get this from openweathermap.org
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // For demo purposes, we'll use mock data if no API key is provided
  static const bool _useMockData = _apiKey == 'YOUR_OPENWEATHER_API_KEY';

  Future<String> getCurrentWeather({String? city}) async {
    if (_useMockData) {
      return _getMockWeather();
    }

    try {
      // Get city from preferences if not provided
      city ??= await _getSavedCity();
      
      final url = '$_baseUrl?q=$city&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _formatWeatherData(data);
      } else {
        return 'Sorry, I couldn\'t get the weather information right now.';
      }
    } catch (e) {
      debugPrint('Weather service error: $e');
      return _getMockWeather();
    }
  }

  String _formatWeatherData(Map<String, dynamic> data) {
    final cityName = data['name'];
    final country = data['sys']['country'];
    final temp = data['main']['temp'].round();
    final feelsLike = data['main']['feels_like'].round();
    final description = data['weather'][0]['description'];
    final humidity = data['main']['humidity'];
    final windSpeed = data['wind']['speed'];

    return '''
🌤️ Weather in $cityName, $country:

🌡️ Temperature: ${temp}°C (feels like ${feelsLike}°C)
☁️ Conditions: ${description.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}
💧 Humidity: ${humidity}%
🌬️ Wind Speed: ${windSpeed} m/s
''';
  }

  String _getMockWeather() {
    final mockWeatherData = [
      '🌤️ Weather in Your City:\n\n🌡️ Temperature: 22°C (feels like 24°C)\n☁️ Conditions: Partly Cloudy\n💧 Humidity: 65%\n🌬️ Wind Speed: 3.2 m/s',
      '☀️ Weather in Your City:\n\n🌡️ Temperature: 28°C (feels like 30°C)\n☁️ Conditions: Sunny\n💧 Humidity: 45%\n🌬️ Wind Speed: 2.1 m/s',
      '🌧️ Weather in Your City:\n\n🌡️ Temperature: 18°C (feels like 16°C)\n☁️ Conditions: Light Rain\n💧 Humidity: 85%\n🌬️ Wind Speed: 4.5 m/s',
    ];
    
    final now = DateTime.now();
    final index = now.day % mockWeatherData.length;
    return mockWeatherData[index];
  }

  Future<String> _getSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('weather_city') ?? 'London'; // Default city
  }

  Future<void> setSavedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weather_city', city);
  }

  // Get weather for specific location
  Future<String> getWeatherForLocation(String location) async {
    return await getCurrentWeather(city: location);
  }

  // Get extended forecast (mock implementation)
  Future<String> getExtendedForecast() async {
    return '''
📅 5-Day Forecast:

Today: 22°C - Partly Cloudy
Tomorrow: 25°C - Sunny
Day 3: 19°C - Rainy
Day 4: 23°C - Cloudy
Day 5: 26°C - Sunny

Note: This is a sample forecast. For accurate weather data, please configure the OpenWeatherMap API key.
''';
  }

  // Weather tips based on conditions
  String getWeatherTips(String conditions) {
    final lowerConditions = conditions.toLowerCase();
    
    if (lowerConditions.contains('rain')) {
      return '☔ Don\'t forget your umbrella today!';
    } else if (lowerConditions.contains('sunny') || lowerConditions.contains('clear')) {
      return '😎 Perfect day to go outside! Don\'t forget sunscreen.';
    } else if (lowerConditions.contains('snow')) {
      return '❄️ Bundle up and drive carefully!';
    } else if (lowerConditions.contains('cloud')) {
      return '☁️ Nice mild weather today!';
    } else {
      return '🌤️ Have a great day!';
    }
  }
}
