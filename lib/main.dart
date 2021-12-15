// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'components/camera_page.dart';
import 'components/register_page.dart';

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
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/third': (context) => const CameraPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              Navigator.pushNamed(context, '/register');
            },
            child: Text("Don't have an account ? Register"),
          ),
        ],
      )),
    );
  }
}
