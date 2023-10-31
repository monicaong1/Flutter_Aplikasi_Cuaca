import 'dart:convert';
import 'package:flutter/material.dart';
import 'key.dart' as key;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Cuaca Iklim'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _kotaInput;

  Future<void> goToNextPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(builder: (context) {
        return ChangeCity();
      }),
    );

    if (result != null && result.containsKey('kota')) {
      _kotaInput = result['kota'].toString();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              goToNextPage(context);
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'images/back.png',
              fit: BoxFit.fill,
              color: Colors.white.withOpacity(0.9),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 11, 20, 0),
            child: Text(
              _kotaInput ?? key.defaultCity,
              style: kotaStyle,
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset('images/light_rain.png'),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(0.0, 150, 20, 0),
            child: updateTempWidget(_kotaInput ?? key.defaultCity),
          ),
        ],
      ),
    );
  }
}

TextStyle kotaStyle = const TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.w500,
  color: Colors.black,
);

class ChangeCity extends StatelessWidget {
  final TextEditingController kotaFieldController = TextEditingController();

  ChangeCity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kota'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'images/white_snow.png',
              fit: BoxFit.fill,
            ),
          ),
          ListView(
            children: [
              ListTile(
                title: TextField(
                  decoration: const InputDecoration(hintText: 'Cari Kota'),
                  controller: kotaFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: TextButton(
                  onPressed: () {
                    Navigator.pop(context, {'kota': kotaFieldController.text});
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                  child: const Text(
                    'Pilih',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>?> getWeather(String apiId, String city) async {
  final response = await http.get(Uri.parse(
      'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch weather data');
  }
}

Widget updateTempWidget(String city) {
  return FutureBuilder<Map<String, dynamic>?>(
    future: getWeather(key.apiId, city),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData) {
        Map<String, dynamic> data = snapshot.data!;

        return Container(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  '${data['main']['temp']}°C',
                  style: tempStyle(),
                ),
                subtitle: ListTile(
                  title: Text(
                    // ignore: prefer_interpolation_to_compose_strings
                    "Humidity: " +
                        data['main']['humidity'].toString() +
                        '%\n'
                            "Wind: " +
                        data['wind']['speed'].toString() +
                        'km/h\n'
                            "Min : " +
                        data['main']['temp_min'].toString() +
                        'C\n'
                            "Max : " +
                        data['main']['temp_max'].toString() +
                        'C\n',
                    style: tempStyle(),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    },
  );
}

TextStyle tempStyle() {
  return const TextStyle(
    fontSize: 30,
    color: Color.fromARGB(255, 50, 33, 33),
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
  );
}
