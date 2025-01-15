import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_5days_model.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<WeatherModel> fetchWeather(
      {required double lat, required double lon}) async {
    final String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to load weather data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to fetch weather data: $error');
    }
  }

  Future<WeatherModel> fetchWeatherCityName({required String cityName}) async {
    final String url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        print(response.reasonPhrase);
        throw Exception(
            'Failed to load weather data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to fetch weather data: $error');
    }
  }

  Future<List<double>> getUserCoords() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();

    return [position.latitude, position.longitude];
  }

  Future<String> getCityNameAndCountry(List<double> coords) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(coords[0], coords[1]);
    String? country = placemarks[0].country;

    final String url =
        'https://api.openweathermap.org/geo/1.0/reverse?lat=${coords[0]}&lon=${coords[1]}&limit=5&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return jsonResponse[0]['name'] != ''
              ? '${jsonResponse[0]['name']}, $country'
              : 'Unknown location';
        } else {
          throw Exception('No location data found for the given coordinates.');
        }
      } else {
        print(response.reasonPhrase);
        throw Exception(
            'Failed to load weather data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to fetch weather data: $error');
    }
  }

  Future<Weather5DaysModel> fetchWeather5Days(
      {required double lat, required double lon}) async {
    final String url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Weather5DaysModel.fromJson(json.decode(response.body));
      } else {
        print(response.reasonPhrase);
        throw Exception(
            'Failed to load weather data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to fetch weather data: $error');
    }
  }

  Future<Weather5DaysModel> fetchWeather5DaysCityName(
      {required String cityName, int? cnt}) async {
    String url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&units=metric&appid=$apiKey';
    if (cnt != null) {
      url += '&cnt=$cnt';
    }
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Weather5DaysModel.fromJson(json.decode(response.body));
      } else {
        print(response.reasonPhrase);
        throw Exception(
            'Failed to load weather data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to fetch weather data: $error');
    }
  }

  Map<String, dynamic> getFiveDaysForecast(Weather5DaysModel data) {
    final Map<String, List<dynamic>> groupedData = {};

    for (var forecast in data.list) {
      final date = DateFormat('yyyy-MM-dd').format(forecast.dtTxt);
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(forecast);
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final Map<String, dynamic> fiveDaysForecast = {};

    groupedData.forEach((date, forecasts) {
      if (date != today) {
        double tempMin = double.infinity;
        double tempMax = double.negativeInfinity;
        final Map<String, int> iconFrequency = {};
        final Map<String, int> descriptionFrequency = {};

        for (var forecast in forecasts) {
          tempMin = tempMin < forecast.main.temp ? tempMin : forecast.main.temp;
          tempMax = tempMax > forecast.main.temp ? tempMax : forecast.main.temp;

          final icon = forecast.weather[0].icon;
          iconFrequency[icon] = (iconFrequency[icon] ?? 0) + 1;

          final description = forecast.weather[0].description;
          descriptionFrequency[description] =
              (descriptionFrequency[description] ?? 0) + 1;
        }

        final mostFrequentIcon = iconFrequency.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        final mostFrequentDescription = descriptionFrequency.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        fiveDaysForecast[date] = {
          'tempMin': tempMin,
          'tempMax': tempMax,
          'icon': mostFrequentIcon,
          'description': mostFrequentDescription,
        };
      }
    });
    return fiveDaysForecast;
  }
}
