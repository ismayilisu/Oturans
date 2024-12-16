import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'location.dart';

class otp extends StatefulWidget {
  final String verificationId;
  final String name;
  final String phonenumber;
  const otp(
      {super.key,
      required this.verificationId,
      required this.name,
      required this.phonenumber});

  @override
  State<otp> createState() => _otpState();
}

class _otpState extends State<otp> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get otp => _controllers.map((controller) => controller.text).join();

  void _verifyOTP() async {
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Please enter a 6-digit OTP",
        style: TextStyle(color: Colors.black),
      )));
      return;
    }
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String verificationId = widget.verificationId;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);

    try {
      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone number verified successfully")));
      await _auth.signInWithCredential(credential);
      _firestore.collection('DATA');
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('DATA').doc(widget.phonenumber);
      DocumentSnapshot documentSnapshot = await userDoc.get();
      if (!documentSnapshot.exists) {
        await userDoc.set({
          'Temp Name': widget.name,
          'Phone Number': widget.phonenumber,
          'Bookings': 0,
        });
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  location(name: widget.name, phonenumber: widget.phonenumber)),
          (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("OTP verification failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: Colors.white)),
            //main container
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    //1st container

                    height: MediaQuery.of(context).size.height * 0.4,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 180,
                        ),
                        Container(
                          //for text1

                          child: Text(
                            "ENTER OTP",
                            style: TextStyle(
                                fontSize: 42,
                                fontFamily: "Sour",
                                color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Text(
                              "We have Sent an OTP to ${widget.phonenumber}"),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 60,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: List.generate(6, (index) {
                                    return Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: TextField(
                                          controller: _controllers[index],
                                          focusNode: _focusNodes[index],
                                          maxLength: 1,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              counterText: "",
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(25))),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.black,
                                                    width: 8,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              25)))),
                                          onChanged: (value) {
                                            if (value.length == 1 &&
                                                index < 5) {
                                              _focusNodes[index + 1]
                                                  .requestFocus();
                                            }
                                            if (value.isEmpty && index > 0) {
                                              _focusNodes[index - 1]
                                                  .requestFocus();
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.black)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Server is under maintenance, Please try again later ")));
                                },
                                label: const Text("Resend OTP"),
                              ),
                              const SizedBox(
                                width: 25,
                              ),
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStatePropertyAll(Colors.white),
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.black),
                                ),
                                onPressed: () {
                                  _verifyOTP();
                                },
                                label: Text("Verify"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
