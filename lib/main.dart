import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'location.dart';
import 'temp_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("initialized");
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  print('awaiting token');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'oturans',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(), // Set the home page here
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _instance2 = FirebaseFirestore.instance;
  bool _isCheckingLoginStatus = true;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() async {
    User? user = _auth.currentUser;
    print(user);
    if (user != null) {
      String? uid = user.phoneNumber;
      print(uid);
      DocumentSnapshot userdoc =
          await _instance2.collection("DATA").doc(uid).get();
      print(userdoc.data());
      Map<String, dynamic> userdata = userdoc.data() as Map<String, dynamic>;
      print(userdata['Temp Name']);
      print(userdata['Phone Number']);
      // User is logged in, navigate to the location screen
     

      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('navigating');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => location(
              name: userdata['Temp Name'], // Replace with actual data
              phonenumber: userdata['Phone Number'], // Replace with actual data
            ),
          ),
        );
      });
    } else {
      // No user is logged in, navigate to the login screen

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyWidget(), // Replace with your login screen
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLoginStatus) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.black,
        )),
      );
    }

    return Scaffold();
  }
}
