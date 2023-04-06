import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'constans/api.dart';
import 'constans/app_color.dart';
import 'constans/app_style.dart';
import 'constans/app_text.dart';
import 'model/weather.dart';

List<String> cities = [
  'Bishkek',
  'Osh',
  'Talas',
  'Naryn',
  'Jalal-abad',
  'Batken',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Weather? weather;
  Future<void> weatherLocation() async {
    setState(() {
      weather = null;
    });
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always &&
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        final dio = Dio();
        final res = await dio.get(
          ApiConst.getLocator(position.latitude, position.longitude),
        );
        if (res.statusCode == 200) {
          weather = Weather(
            id: res.data['current']['weather'][0]['id'],
            main: res.data['current']['weather'][0]['main'],
            description: res.data['current']['weather'][0]['description'],
            icon: res.data['current']['weather'][0]['icon'],
            city: res.data['timezone'],
            temp: res.data['current']['temp'],
            // country: res.data[''],
          );
        }
        setState(() {});
      }
    } else {
      Position position = await Geolocator.getCurrentPosition();
      final dio = Dio();
      final res = await dio.get(
        ApiConst.getLocator(position.latitude, position.longitude),
      );
      if (res.statusCode == 200) {
        weather = Weather(
          id: res.data['current']['weather'][0]['id'],
          main: res.data['current']['weather'][0]['main'],
          description: res.data['current']['weather'][0]['description'],
          icon: res.data['current']['weather'][0]['icon'],
          city: res.data['timezone'],
          temp: res.data['current']['temp'],
          // country: res.data['']
        );
      }
      setState(() {});
    }
  }

  Future<void> fetchData([String? name]) async {
    final dio = Dio();
    await Future.delayed(
      const Duration(seconds: 2),
    );
    final res = await dio.get(
      ApiConst.address(name ?? 'bishkek'),
    );
    if (res.statusCode == 200) {
      weather = Weather(
        id: res.data['weather'][0]['id'],
        main: res.data['weather'][0]['main'],
        description: res.data['weather'][0]['description'],
        icon: res.data['weather'][0]['icon'],
        city: res.data['name'],
        temp: res.data['main']['temp'],
        // country: res.data['sys']['country'],
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text(
          AppText.appBarTitle,
          style: AppStyle.appBarStytle,
        ),
        centerTitle: true,
      ),
      body: weather == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/weather.jpg'),
                    fit: BoxFit.cover),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          showButtom();
                        },
                        color: AppColors.white,
                        iconSize: 47,
                        icon: const Icon(
                          Icons.location_city_outlined,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await weatherLocation();
                        },
                        iconSize: 47,
                        icon: const Icon(
                          Icons.near_me,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Text(weather!.city, style: AppStyle.city),
                  const SizedBox(
                    height: 27,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 50,
                      ),
                      Text(
                        weather!.description.replaceAll(' ', '\n'),
                        style: AppStyle.text1,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 40,
                      ),
                      Text('${(weather!.temp - 273.15).toInt()}',
                          style: AppStyle.body1),
                      Image.network(
                        ApiConst.getIcon(weather!.icon, 4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void showButtom() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
              color: Colors.black38,
              border: Border.all(color: AppColors.white),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    setState(() {
                      weather = null;
                    });
                    fetchData(city);
                    Navigator.pop(context);
                  },
                  title: Text(city),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
