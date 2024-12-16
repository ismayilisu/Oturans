import 'package:flutter/material.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              children: [
                Container(
                  // height: MediaQuery.of(context).size.height * 0.3,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Text("COMING SOON"),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
