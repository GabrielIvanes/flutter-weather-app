import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_5days_model.dart';

class HourlyForecastWidget extends StatelessWidget {
  final Weather5DaysModel weather5DaysData;

  const HourlyForecastWidget({super.key, required this.weather5DaysData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Theme.of(context).primaryColor),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text('Hourly forecasts',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              itemCount: 9,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final forecast = weather5DaysData.list[index];
                return Column(
                  children: [
                    Text(DateFormat('HH:mm').format(forecast.dtTxt),
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    Image.network(
                        'http://openweathermap.org/img/wn/${forecast.weather[0].icon}.png'),
                    Text(
                      '${forecast.main.temp.toStringAsFixed(0)}°',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
