import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io' show Platform;
import "secondpage.dart";
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Connection à votre poubelle';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  pushToScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OtherScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
    ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            style: style,
            onPressed: () => pushToScreen(context),
            child: const Text('Connection'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: null,
            child: const Text('Deconnection'),
          ),
        ],
      ),
    );
  }
}

class OtherScreen extends StatefulWidget {
  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen> {

  Future<List<WifiNetwork>> loadWifiList() async {
    List<WifiNetwork> htResultNetwork;

    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      htResultNetwork = <WifiNetwork>[];
    }

    return htResultNetwork;
  }

  String url = "http://91.121.71.10:3000/private/bin";
  List<WifiNetwork?>? _htResultNetwork;
  String? scanWifi = "";
  //   //String url = 'localhost:3000/private/bin';
  pushToScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OtherScreen2()),
    );
  }
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connection screen'),
      ),
      body: Center(
        child: TextField(
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
          ),
          onSubmitted: (String value) async {
            _htResultNetwork = await loadWifiList();
            for (var element in _htResultNetwork!) { scanWifi = _htResultNetwork!.first!.ssid;}
            print(scanWifi);
            if (scanWifi!.contains('BetterEarth') == true) {
              print(scanWifi);} else {
              print("Doesn't find BetterEarthItem");
            }
            var body = jsonEncode({
              "email": "test@test.com",
              "password": "azerty"
            });
            final test = await http.post(Uri.parse("http://91.121.71.10:3000/auth/login"),
                headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            }, body: body);
            var access = jsonDecode(test.body)["token"].toString();
            print(access);
            var bod = jsonEncode({
              "serialNumber": "$value",
            });
            final response = await http.post(Uri.parse("http://91.121.71.10:3000/private/bin"), headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $access',
            }, body: bod);
            print(response.body);
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thanks!'),
                  content: Text(
                      'You are connection was succesful'
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        pushToScreen(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}