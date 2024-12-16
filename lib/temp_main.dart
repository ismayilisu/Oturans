import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'otp.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phonenumber = TextEditingController();

  // bool rememberme = false;
  late String _verificationid;

  // @override
  // void initState() {
  //   super.initState();
  //   //listenerfunction();
  // }
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });

    // Check if a user is already logged in
    //  _checkUserLoggedIn();
  }

  // void _checkUserLoggedIn() async {
  //   User? user = _auth.currentUser;

  //   if (user != null) {
  //     // User is logged in, navigate to the home screen or main app screen
  //     print("User is logged in: ${user.phoneNumber}");
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => location(
  //           name: 'sai',
  //           phonenumber: 'dhdhdh',
  //         ), // Replace with your main screen
  //       ),
  //     );
  //   } else {
  //     // No user is logged in, navigate to the login screen
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => MyHomePage(), // Replace with your login screen
  //       ),
  //     );
  //   }
  // }

  // void listenerfunction() async {
  //   User? user = _auth.currentUser;
  //   print(user);
  //   if (user != null) {
  //     String uid = user.uid;
  //     print(uid);

  //     try {
  //       DocumentSnapshot userdoc =
  //           await FirebaseFirestore.instance.collection("DATA").doc(uid).get();
  //       if (userdoc.exists) {
  //         Map<String, dynamic> userData =
  //             userdoc.data() as Map<String, dynamic>;
  //         Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => location(
  //                     name: userData['Temp name'],
  //                     phonenumber: userData['Phone Number'])),
  //             (Route<dynamic> route) => false);
  //       }
  //     } catch (e) {}
  //   } else {
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => MyHomePage()),
  //         (Route<dynamic> route) => false);
  //   }
  // }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _verifyphonenumber() async {
    await Future.delayed(Duration(seconds: 2));

    String phone = _phonenumber.text.trim();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
      
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Phone number verified Successfully')));
        setState(() {
          _isLoading = true;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (_phonenumber.text.length != 13) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid Contact details'),
            duration: Duration(seconds: 1),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification Failed : ${e.message}')));
        }
        setState(() {
          _isLoading = true;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationid = verificationId;
          print(_verificationid);
        }); //edited for cicle in firest page

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => otp(
                verificationId: _verificationid,
                name: _name.text,
                phonenumber: _phonenumber.text),
          ),
          (Route<dynamic> route) => false,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationid = verificationId;
        });
      },
    );
  }

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        const SizedBox(
                          height: 80,
                        ),
                        Container(
                          height: 200,
                          width: double.infinity,
                          child: Center(
                              child: Image.asset("assets/img/padlock.png")),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "PLEASE SIGN IN TO CONTINUE",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: TextField(
                                    focusNode: f1,
                                    controller: _name,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle_outlined,
                                          size: 50,
                                        ),
                                        prefixIconColor: Colors.black,
                                        hintText: ("Enter Your Full Name"),
                                        labelText: 'UserName',
                                        fillColor: Colors.yellow.shade600,
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 3))),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: TextField(
                                    focusNode: f2,
                                    controller: _phonenumber,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.call,
                                          size: 35,
                                        ),
                                        prefixIconColor: Colors.black,
                                        hintText: ("Format : +911234567890"),
                                        labelText: 'Contact',
                                        fillColor: Colors.yellow.shade600,
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 3))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: _isLoading
                              ? TextButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all(Colors.black),
                                      foregroundColor: WidgetStateProperty.all(
                                        Colors.white,
                                      )),
                                  onPressed: () {
                                    f1.unfocus();
                                    f2.unfocus();
                                    setState(() {
                                      _isLoading = false;
                                      if (_name.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('UserName is Empty'),
                                          duration: Duration(seconds: 1),
                                        ));
                                        _isLoading = true;
                                      } else if (_phonenumber.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text('ContactField is Empty'),
                                          duration: Duration(seconds: 1),
                                        ));
                                        _isLoading = true;
                                      } else {
                                        _verifyphonenumber();
                                      }
                                    });
                                  },
                                  label: Text("Login"),
                                  icon: Icon(Icons.login_sharp))
                              : CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "CodeInBig Ltd.",
                              style: TextStyle(color: Colors.black),
                            )),
                      ]),
                    )),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
