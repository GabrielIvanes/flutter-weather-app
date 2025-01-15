// To parse this JSON data, do
//
//     final city = cityFromJson(jsonString);

import 'dart:convert';

List<City> cityFromJson(String str) {
  final List<dynamic> jsonList = json.decode(str);
  return jsonList.map((x) => City.fromJson(x)).toList();
}

String cityToJson(List<City> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class City {
  String id;
  String name;
  String country;
  String admin1;
  String lat;
  String lon;
  String pop;

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.admin1,
    required this.lat,
    required this.lon,
    required this.pop,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json["id"] is String ? json["id"] : json["id"].toString(),
      name: json["name"] is String ? json["name"] : json["name"].toString(),
      country: json["country"] is String
          ? json["country"]
          : json["country"].toString(),
      admin1:
          json["admin1"] is String ? json["admin1"] : json["admin1"].toString(),
      lat: json["lat"] is String ? json["lat"] : json["lat"].toString(),
      lon: json["lon"] is String ? json["lon"] : json["lon"].toString(),
      pop: json["pop"] is String ? json["pop"] : json["pop"].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country": country,
        "admin1": admin1,
        "lat": lat,
        "lon": lon,
        "pop": pop,
      };
}
