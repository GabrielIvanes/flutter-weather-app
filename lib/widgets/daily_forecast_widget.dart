import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyForecastWidget extends StatelessWidget {
  final Map<String, dynamic> fiveDaysForecast;

  const DailyForecastWidget({super.key, required this.fiveDaysForecast});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, color: Theme.of(context).primaryColor),
              Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text('Daily forecasts',
                      style: TextStyle(color: Theme.of(context).primaryColor))),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: Row(
              children: List.generate(
                fiveDaysForecast.length,
                (index) {
                  final keys = fiveDaysForecast.keys.toList();
                  final dateKey = keys[index];
                  final dayForecast = fiveDaysForecast[dateKey];

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            index == 0
                                ? 'Tomorrow'
                                : DateFormat('E')
                                    .format(DateTime.parse(dateKey)),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        Image.network(
                          'http://openweathermap.org/img/wn/${dayForecast['icon']}.png',
                        ),
                        Text(
                          '${dayForecast['tempMin'].toStringAsFixed(0)}° / ${dayForecast['tempMax'].toStringAsFixed(0)}°',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
