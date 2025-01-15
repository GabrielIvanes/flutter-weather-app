import 'package:flutter/material.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/models/city_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:weather_app/utils/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final SearchController controller = SearchController();
  late Future<List<City>> _cities;
  late WeatherService _weatherService;
  List<City> _favoritesCities = [];
  final Map<String, WeatherModel?> _weatherData = {};

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService(apiKey: dotenv.env['WEATHER_API_KEY']!);
    _cities = loadCities();
    _loadFavoritesCities();
  }

  Future<void> _loadFavoritesCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? storedCities = prefs.getStringList('favoritesCities');

      if (storedCities != null) {
        setState(() {
          _favoritesCities = storedCities
              .map((cityJson) => City.fromJson(jsonDecode(cityJson)))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favoritesCities');
      setState(() {
        _favoritesCities = [];
      });
    }
  }

  Future<void> _fetchWeatherForCity(City city) async {
    try {
      final weather =
          await _weatherService.fetchWeatherCityName(cityName: city.name);
      setState(() {
        _weatherData[city.id] = weather;
      });
    } catch (e) {
      print('Error fetching weather for ${city.name}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<City>>(
      future: _cities,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final cities = snapshot.data!;
        return Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SearchAnchor(
                searchController: controller,
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).cardColor,
                    ),
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    leading: Icon(Icons.search,
                        color: Theme.of(context).primaryColor),
                    hintText: 'Search for a city ...',
                    hintStyle: WidgetStatePropertyAll(
                      TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onTap: () => controller.openView(),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  final String input = controller.value.text.toLowerCase();

                  final List<City> filteredCities = cities
                      .where((city) =>
                          '${city.name.toLowerCase()}, ${city.admin1.toLowerCase()}, ${city.country.toLowerCase()}'
                              .startsWith(input))
                      .toList();

                  if (filteredCities.isEmpty) {
                    return [
                      ListTile(
                        title: Text('No city found',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                      ),
                    ];
                  }

                  return filteredCities.map((city) {
                    return ListTile(
                      title:
                          Text('${city.name}, ${city.admin1}, ${city.country}'),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final String selectedText =
                            '${city.name}, ${city.admin1}, ${city.country}';
                        setState(() {
                          if (!_favoritesCities.any(
                              (favoriteCity) => favoriteCity.id == city.id)) {
                            _favoritesCities.add(city);
                          }
                        });
                        prefs.setStringList(
                            'favoritesCities',
                            _favoritesCities
                                .map((city) => jsonEncode(city.toJson()))
                                .toList());
                        controller.closeView(selectedText);
                        controller.text = selectedText;
                      },
                    );
                  }).toList();
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _favoritesCities.isEmpty
                  ? Center(
                      child: Text(
                        'No favorite cities yet',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _favoritesCities.length,
                      itemBuilder: (context, index) {
                        final city = _favoritesCities[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              title: Text(
                                '${city.name}, ${city.admin1}, ${city.country}',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              subtitle: FutureBuilder<void>(
                                future: _fetchWeatherForCity(city),
                                builder: (context, snapshot) {
                                  final weather = _weatherData[city.id];
                                  if (weather == null) {
                                    return const SizedBox(
                                      height: 2,
                                      child: LinearProgressIndicator(),
                                    );
                                  }
                                  return Text(
                                    '${weather.weather[0].description}   ${weather.main.temp.round()}°C',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  );
                                },
                              ),
                              onTap: () {
                                final navigationProvider =
                                    Provider.of<NavigationProvider>(context,
                                        listen: false);
                                navigationProvider.updateIndex(1,
                                    cityName: city.name);
                              },
                              trailing: IconButton(
                                icon: Icon(Icons.delete,
                                    color: Theme.of(context).primaryColor),
                                onPressed: () async {
                                  setState(() {
                                    _favoritesCities.removeAt(index);
                                    _weatherData.remove(city.id);
                                  });
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setStringList(
                                    'favoritesCities',
                                    _favoritesCities
                                        .map(
                                            (city) => jsonEncode(city.toJson()))
                                        .toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
