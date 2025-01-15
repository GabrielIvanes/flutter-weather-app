import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/city_model.dart';
import 'package:weather_app/services/chatbot_service.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/utils.dart';
import 'package:weather_app/widgets/travel_recommendations_widget.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  final SearchController controller = SearchController();
  late Future<List<City>> _cities;
  late ChatbotService _chatbotService;
  late WeatherService _weatherService;
  Map<String, dynamic> _fiveDaysForecast = {};
  int _selectedDays = 1;
  String _selectedCityName = '';
  String? _recommendations;
  bool _isLoading = false;

  Future<void> _handleSearch() async {
    if (controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a destination first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _recommendations = null;
    });

    try {
      final weatherData = await _weatherService.fetchWeather5DaysCityName(
        cityName: _selectedCityName.split(',')[0],
        cnt: (_selectedDays + 1) * 8,
      );
      setState(() {
        _fiveDaysForecast = _weatherService.getFiveDaysForecast(weatherData);
      });

      DateTime today = DateTime.now();
      DateTime cutoffDate = today.add(Duration(days: _selectedDays));

      setState(() {
        _fiveDaysForecast.removeWhere((dateString, _) {
          DateTime date = DateTime.parse(dateString);
          return date.isBefore(today) ||
              date.isAfter(cutoffDate) ||
              date.isAtSameMomentAs(today);
        });
      });

      final prompt = '''
I am building a travel assistant. Based on the following weather forecast, generate a response that includes:
1. An exhaustive list of recommended items to pack in the suitcase for the next $_selectedDays days.
2. Activities suitable for the weather conditions.

Here is the weather forecast data:
{
  "location": "$_selectedCityName",
  "forecast": [
    $_fiveDaysForecast
  ]
}

Write your answer exactly as follows, using the same format and the following two sections:
- **Suitcase Recommendations**: List specific items to pack based on the weather. Just list the items with bullet points, no need to explain and no need to specify the days.
- **Recommended Activities**: Suggest activities for each day that are adapted to the forecast. Lists the suggestions with a bullet point list for each day in the format ‘- day: suggestions’. I want at least one suggestion for every day. Group activities by day.

Make sure the suggestions are concise and practical. Use the character '-' to indicate a bullet point. Don't make extra tabs.
''';

      final response = await _chatbotService.generateResponse(prompt);
      setState(() {
        _recommendations = response;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _cities = loadCities();
    _chatbotService = ChatbotService(apiKey: dotenv.env['CHATBOT_API_KEY']!);
    _weatherService = WeatherService(apiKey: dotenv.env['WEATHER_API_KEY']!);
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
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SearchAnchor(
                      searchController: controller,
                      builder:
                          (BuildContext context, SearchController controller) {
                        return SearchBar(
                          backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).cardColor,
                          ),
                          controller: controller,
                          padding: const WidgetStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
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
                        final String input =
                            controller.value.text.toLowerCase();

                        final List<City> filteredCities = cities
                            .where((city) =>
                                '${city.name.toLowerCase()}, ${city.admin1.toLowerCase()}, ${city.country.toLowerCase()}'
                                    .startsWith(input))
                            .toList();

                        if (filteredCities.isEmpty) {
                          return [
                            const ListTile(
                              title: Text('Aucune ville trouvée'),
                            ),
                          ];
                        }

                        return filteredCities.map((city) {
                          return ListTile(
                            title: Text(
                                '${city.name}, ${city.admin1}, ${city.country}'),
                            onTap: () async {
                              final String selectedText =
                                  '${city.name}, ${city.admin1}, ${city.country}';
                              controller.closeView(selectedText);
                              controller.text = selectedText;
                              setState(() {
                                _selectedCityName =
                                    '${city.name}, ${city.admin1}, ${city.country}';
                              });
                            },
                          );
                        }).toList();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: DropdownButton<int>(
                        dropdownColor: Theme.of(context).cardColor,
                        value: _selectedDays,
                        isExpanded: true,
                        underline: Container(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).primaryColor,
                        ),
                        items: List.generate(4, (index) => index + 1)
                            .map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              value.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedDays = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: _handleSearch,
              child: Text(
                'Search',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (_recommendations != null)
              Expanded(
                child: SingleChildScrollView(
                  child: TravelRecommendationsWidget(
                    response: _recommendations!,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
