import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils/utils.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final WeatherModel weatherData;
  final String country;

  const CurrentWeatherWidget({
    super.key,
    required this.weatherData,
    required this.country,
  });

  String _getBackgroundGif(String weatherDescription, bool isDay) {
    switch (weatherDescription.toLowerCase()) {
      case 'clear':
        return isDay ? 'assets/gifs/sun.gif' : 'assets/gifs/night.gif';
      case 'clouds':
        return isDay
            ? 'assets/gifs/cloudy.gif'
            : 'assets/gifs/cloudy-night.gif';
      case 'rain':
      case 'drizzle':
        return 'assets/gifs/rain.gif';
      case 'snow':
        return 'assets/gifs/snow.gif';
      case 'thunderstorm':
        return 'assets/gifs/thunder.gif';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
        return 'assets/gifs/mist.gif';
      case 'tornado':
        return 'assets/gifs/tornado.gif';
      case 'squall':
        return 'assets/gifs/wind.gif';
      default:
        return isDay ? 'assets/gifs/sun.gif' : 'assets/gifs/night.gif';
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage(_getBackgroundGif(
              weatherData.weather[0].main,
              weatherData.dt < weatherData.sys.sunset &&
                  weatherData.dt > weatherData.sys.sunrise)),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 45),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Text(
                  '${weatherData.name}, $country',
                  style: TextStyle(
                      fontSize: 17, color: Theme.of(context).primaryColor),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      navigationProvider.updateIndex(0);
                    },
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      navigationProvider.updateIndex(1);
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(weatherData.main.temp).toStringAsFixed(0)}°',
                            style: TextStyle(
                                height: 0.8,
                                fontSize: 75,
                                color: Theme.of(context).primaryColor),
                          ),
                          Text(
                            'Feels like ${(weatherData.main.feelsLike).toStringAsFixed(0)}°',
                            style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).primaryColor),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 5),
                      child: Text(
                          '${(weatherData.main.tempMin).toStringAsFixed(0)}° / ${(weatherData.main.tempMax).toStringAsFixed(0)}°',
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor)),
                    )
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.network(
                          'http://openweathermap.org/img/wn/${weatherData.weather[0].icon}@2x.png',
                        ),
                        Text(
                          weatherData.weather[0].main,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 45),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                getDateOfUser(-1, weatherData.timezone, 'MMMM d, HH:mm'),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
