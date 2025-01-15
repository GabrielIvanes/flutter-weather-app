import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/city_model.dart';

String getDateOfUser(int timestamp, int timezone, String format) {
  DateTime utcNow = timestamp == -1
      ? DateTime.now().toUtc()
      : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);

  DateTime userLocalTime = utcNow.add(Duration(seconds: timezone));

  return DateFormat(format).format(userLocalTime);
}

Future<List<City>> loadCities() async {
  final String response = await rootBundle.loadString('assets/cities.json');
  return cityFromJson(response);
}
