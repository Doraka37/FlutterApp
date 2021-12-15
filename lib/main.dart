// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];
FirebaseAuth auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserName()),
      ],
      child: const MyApp(),
    ),
  );
}

class UserName with ChangeNotifier, DiagnosticableTreeMixin {
  String _username = "";
  String _password = "";

  String get username => _username;
  String get password => _password;
  // ignore: non_constant_identifier_names
  void SetUserName(value) {
    _username = value;
    notifyListeners();
  }

  void SetPassword(value) {
    _password = value;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('username', username));
    properties.add(StringProperty('password', password));
  }
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
        '/third': (context) => const ThirdRoute(),
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
  @override
  void initState() {
    super.initState();
  }

  void signIn(email, password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } finally {
      print("This is FINALLY Clause and is always executed.");
      Navigator.pushNamed(context, '/third');
    }
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
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'Log In ',
              style: TextStyle(fontFamily: 'Praise', fontSize: 50),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'Please enter your username and password ',
              style: TextStyle(fontFamily: 'Praise', fontSize: 20),
            ),
          ),
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Username'),
            onChanged: (text) {
              context.read<UserName>().SetUserName(text);
            },
          ),
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Password'),
            onChanged: (text) {
              context.read<UserName>().SetPassword(text);
            },
          ),
          ElevatedButton(
              onPressed: () {
                final username = context.read<UserName>().username;
                final password = context.read<UserName>().password;
                signIn(username, password);
              },
              child: const Text('Log In')),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontFamily: 'Praise', fontSize: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/second');
            },
            child: Text("Don't have an account ? Register"),
          ),
        ],
      )),
    );
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

  void register(email, password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    } finally {
      print("This is FINALLY Clause and is always executed.");
      Navigator.pushNamed(context, '/third');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Register',
                style: TextStyle(fontFamily: 'Praise', fontSize: 50),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Please enter your username and password ',
                style: TextStyle(fontFamily: 'Praise', fontSize: 20),
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Username'),
              onChanged: (text) {
                context.read<UserName>().SetUserName(text);
              },
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Password'),
              onChanged: (text) {
                context.read<UserName>().SetPassword(text);
              },
            ),
            ElevatedButton(
                onPressed: () {
                  final username = context.read<UserName>().username;
                  final password = context.read<UserName>().password;
                  register(username, password);
                },
                child: const Text('Register')),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                textStyle: const TextStyle(fontFamily: 'Praise', fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Already have an account ? Log In"),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdRoute extends StatefulWidget {
  const ThirdRoute({Key? key}) : super(key: key);

  @override
  State<ThirdRoute> createState() => _ThirdRouteState();
}

class _ThirdRouteState extends State<ThirdRoute> {
  CameraController? controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? AspectRatio(
              aspectRatio: 1 / controller!.value.aspectRatio,
              child: controller!.buildPreview(),
            )
          : Container(),
    );
  }
}
