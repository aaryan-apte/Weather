import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<dynamic>> fetchTemperature() async {
    List<dynamic> ans = [];

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;

    // final response = await http.get(Uri.parse(
    // 'http://api.weatherapi.com/v1/current.json?key=5cedb11505f24366882135553231708&q=$latitude,$longitude&aqi=yes'));

    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=5cedb11505f24366882135553231708&q=$latitude,$longitude&days=1&aqi=yes&alerts=no'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final tempC = jsonData['current']['temp_c'];
      final condition = jsonData['current']['condition']['text'];

      int time = DateTime.now().hour + 1;
      if (time == 24) {
        time = 0;
      }
      final hourlyData = jsonData['forecast']['forecastday'][0]['hour'][time];

      // final time1 = hourlyData['time'];
      final pm2_5 = hourlyData['air_quality']['pm2_5'];
      final pm10 = hourlyData['air_quality']['pm10'];
      final locationJson = jsonData['location'];
      final location = locationJson['name'] +
          ", " +
          locationJson['region'] +
          ", " +
          locationJson['country'];
      final forecastMessage = hourlyData['condition']['text'];
      final rainChances = hourlyData['chance_of_rain'];
      final snowChances = hourlyData['chance_of_snow'];
      final uv = hourlyData['uv'];
      final cloud = hourlyData['cloud'];
      ans.add(tempC);
      ans.add(condition);
      ans.add(latitude);
      ans.add(longitude);
      ans.add(pm2_5);
      ans.add(pm10);
      ans.add(location);
      ans.add(forecastMessage);
      ans.add(rainChances);
      ans.add(snowChances);
      ans.add(uv);
      ans.add(cloud);

      return ans;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Center(
          child: Text("Weather Application"),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: FutureBuilder(
          future: fetchTemperature(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: Colors.orange,
              ); // Show loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List? data = snapshot.data?.toList();
              var temp = data![0];
              var condition = data[1];
              var latitude = data[2];
              var longitude = data[3];
              var pm2_5 = data[4];
              var pm10 = data[5];
              var location = data[6];
              var forecastMessage = data[7];
              var rainChances = data[8];
              var snowChances = data[9];
              var uv = data[10];
              var cloudCover = data[11];


              String particle = "";

              if (pm2_5 > 15.0 && pm10 > 45.0) {
                particle = "Air quality is bad. Consider putting on a mask.";
              } else{
                particle = "Great air! Mask not necessary.";
              }
              if(uv >= 6){
                particle= "$particle Wear sunscreen. High UV at $uv.";
              }
              // else{
              //   particle = "$particle UV is safe.";
              // }
              if(rainChances > 50.0){
                particle = "$particle Carry an umbrella, it is likely to rain.";
              }
              // else{
              //   particle = "$particle It is not likely to rain.";
              // }
              if(snowChances > 50.0){
                particle = "$particle it is likely to snow!";
              }
              // else{
              //   particle = "$particle It is not likely to snow.";
              // }


              print(particle);

              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('You are at: $location\n'),
                    const SizedBox(height: 10.0),
                    Text('Current Temperature: ${temp.toString()}\n'),
                    const SizedBox(height: 10.0),
                    Text('Current Condition: ${condition.toString()}'),
                    const SizedBox(height: 10.0),
                    Text('Cloud Cover: $cloudCover'),
                    const SizedBox(height: 10.0),
                    // Text('PM 2.5: $pm2_5'),
                    const SizedBox(height: 10.0),
                    Text('PM 10: $pm10'),
                    const SizedBox(height: 10.0),
                    Text("Looks like: $forecastMessage"),
                    const SizedBox(height: 10.0),
                    Text(particle),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
