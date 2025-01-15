import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/weather_5days_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils/utils.dart';
import 'package:weather_app/widgets/current_weather_widget.dart';
import 'package:weather_app/widgets/daily_forecast_widget.dart';
import 'package:weather_app/widgets/hourly_forecast_widget.dart';
import 'package:weather_app/widgets/informational_widget.dart';

class HomePage extends StatefulWidget {
  final String? cityName;

  const HomePage({super.key, this.cityName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WeatherService _weatherService;
  WeatherModel? _weatherData;
  Weather5DaysModel? _weather5DaysData;
  String _country = "";
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _fiveDaysForecast;

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService(apiKey: dotenv.env['WEATHER_API_KEY']!);
    _fetchWeather(widget.cityName);
  }

  Future<void> _fetchWeather(String? cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (cityName == null) {
        final coords = await _weatherService.getUserCoords();
        final result = await _weatherService.getCityNameAndCountry(coords);
        final country = result.split(',')[1];

        final weather =
            await _weatherService.fetchWeather(lat: coords[0], lon: coords[1]);
        final weather5Days = await _weatherService.fetchWeather5Days(
            lat: coords[0], lon: coords[1]);

        setState(() {
          _weatherData = weather;
          _country = country;
          _weather5DaysData = weather5Days;
        });
      } else {
        final weather =
            await _weatherService.fetchWeatherCityName(cityName: cityName);
        final weather5Days = await _weatherService.fetchWeather5Days(
            lat: weather.coord.lat, lon: weather.coord.lon);

        setState(() {
          _weatherData = weather;
          _country = weather.sys.country;
          _weather5DaysData = weather5Days;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _setFiveDaysForecast();
    }
  }

  Future<void> _setFiveDaysForecast() async {
    if (_weather5DaysData != null) {
      setState(() {
        _fiveDaysForecast =
            _weatherService.getFiveDaysForecast(_weather5DaysData!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.white,
              ))
            : _errorMessage != null
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _fetchWeather(widget.cityName),
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ))
                : _weatherData != null
                    ? SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CurrentWeatherWidget(
                                  weatherData: _weatherData!,
                                  country: _country),
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InformationalWidget(
                                          icon: 'assets/images/windy.png',
                                          information:
                                              '${(_weatherData!.wind.speed * 3.6).ceil()} km/h',
                                          title: 'Wind speed'),
                                      InformationalWidget(
                                          icon: 'assets/images/pressure.png',
                                          information:
                                              '${_weatherData!.main.pressure} hpa',
                                          title: 'Pressure'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InformationalWidget(
                                          icon: 'assets/images/humidity.png',
                                          information:
                                              '${_weatherData!.main.humidity} %',
                                          title: 'Humidity'),
                                      InformationalWidget(
                                          icon: 'assets/images/visibility.png',
                                          information:
                                              '${(_weatherData!.visibility / 1000).round()} km',
                                          title: 'Visibility'),
                                    ],
                                  )
                                ],
                              ),
                              HourlyForecastWidget(
                                  weather5DaysData: _weather5DaysData!),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InformationalWidget(
                                      icon: 'assets/images/sunrise.png',
                                      information: getDateOfUser(
                                          _weatherData!.sys.sunrise,
                                          _weatherData!.timezone,
                                          'HH:mm'),
                                      title: 'Sunrise'),
                                  InformationalWidget(
                                      icon: 'assets/images/sunset.png',
                                      information: getDateOfUser(
                                          _weatherData!.sys.sunset,
                                          _weatherData!.timezone,
                                          'HH:mm'),
                                      title: 'Sunset'),
                                ],
                              ),
                              DailyForecastWidget(
                                  fiveDaysForecast: _fiveDaysForecast!),
                            ]),
                      )
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _fetchWeather(widget.cityName),
                            child: const Text('Retry'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )));
  }
}
