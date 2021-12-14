// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Counter()),
      ],
      child: const MyApp(),
    ),
  );
}

class Counter with ChangeNotifier, DiagnosticableTreeMixin {
  int _count = 0;

  int get count => _count;

  void increment(value) {
    _count = value;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/second': (context) => const SecondRoute(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _myPos = 'waiting';
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    Position pos = await _determinePosition();
    setState(() {
      _myPos = 'lat: ${pos.latitude}, long: ${pos.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar uses the app-default Raleway font.
      appBar: AppBar(title: const Text('Custom Fonts')),
      backgroundColor: Colors.purple,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: <Widget>[
          Avatar(),
          Text(
            'Thomas Vigier: ',
            style: TextStyle(fontFamily: 'Praise', fontSize: 40),
          ),
          Text(
            'Mobile Dev',
            style: TextStyle(fontFamily: 'Praise', fontSize: 20),
          ),
          Text(
            'Tasks: ${context.watch<Counter>().count}',
            style: TextStyle(fontFamily: 'Praise', fontSize: 20),
          ),
          Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              )),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontFamily: 'Praise', fontSize: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/second');
            },
            child: Text(
              _myPos,
            ),
          ),
        ],
      )),
    );
  }
}

class Avatar extends StatefulWidget {
  const Avatar({
    Key? key,
  }) : super(key: key);

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/img/Mallard2.jpg'))));
  }
}

class SecondRoute extends StatefulWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  var taskNbr = 0;
  List<String> entries = <String>[];
  String test = 'base';
  List<bool> ckeckedList = <bool>[];
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: <Widget>[
          TopPart(taskNbr: taskNbr),
          ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  children: <Widget>[
                    Center(
                        child: Text(entries[index],
                            style:
                                TextStyle(fontFamily: 'Praise', fontSize: 30))),
                    Checkbox(
                      checkColor: Colors.white,
                      value: ckeckedList[index],
                      onChanged: (bool? value) {
                        setState(() {
                          ckeckedList[index] = value!;
                        });
                      },
                    ),
                  ],
                );
              }),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                color: Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Add Task'),
                      TextField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter a task'),
                        onChanged: (text) {
                          test = text;
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Add'),
                        onPressed: () {
                          setState(() {
                            entries.add(test);
                            ckeckedList.add(false);
                            taskNbr = entries.length;
                          });
                          context.read<Counter>().increment(taskNbr);
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        label: const Text('Approve'),
        icon: const Icon(Icons.plus_one),
        backgroundColor: Colors.pink,
      ),
    );
  }
}

class TopPart extends StatelessWidget {
  const TopPart({
    Key? key,
    required this.taskNbr,
  }) : super(key: key);

  final int taskNbr;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      width: 360,
      color: Colors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            padding: EdgeInsets.only(top: 40.0),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Increase volume by 10',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Text(
            'TO DO LIST',
            style: TextStyle(
                fontFamily: 'Praise', fontSize: 40, color: Colors.black),
          ),
          Text(
            '$taskNbr tasks',
            style: TextStyle(
                fontFamily: 'Praise', fontSize: 20, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
