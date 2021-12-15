import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
