import 'package:flutter/material.dart';

import 'sedan.dart';

class car_price extends StatefulWidget {
  final String name;
  final String phone;
  final String source;
  final String dest;
  final DateTime date;
  final DateTime time;
  final String distance;
  final String estdtime;

  const car_price(
      {super.key,
      required this.name,
      required this.phone,
      required this.source,
      required this.dest,
      required this.date,
      required this.time,
      required this.estdtime,
      required this.distance});

  @override
  State<car_price> createState() => _car_priceState();
}

bool checked1 = false;
bool checked2 = false;
bool checked3 = false;
int pool = 0;

class _car_priceState extends State<car_price> {
  void _showbottomsheet(BuildContext context, String text) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: StatefulBuilder(
                builder: (BuildContext buildcontext, StateSetter setState) {
              return Container(
                height: 350,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                child: Column(
                  children: [
                    Text("PREFERRED POOLING"),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.all(
                              Radius.circular(25),
                            )),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Checkbox(
                                  checkColor: Colors.black,
                                  shape: CircleBorder(
                                      side: BorderSide.none, eccentricity: 0.6),
                                  activeColor: Colors.black,
                                  value: checked1,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checked1 = value!;
                                      if (checked1) {
                                        checked2 = false;
                                        checked3 = false;
                                        pool = 2;
                                      }
                                    });
                                  },
                                ),
                                Text("Two Person Pool"),
                                Icon(Icons.people_alt),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Checkbox(
                                    checkColor: Colors.black,
                                    shape: CircleBorder(
                                        side: BorderSide.none,
                                        eccentricity: 0.6),
                                    activeColor: Colors.black,
                                    value: checked2,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checked2 = value!;
                                        if (checked2) {
                                          checked1 = false;
                                          checked3 = false;
                                          pool = 1;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Text("Single Person Pool"),
                                Icon(Icons.person),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Checkbox(
                                  checkColor: Colors.black,
                                  shape: CircleBorder(
                                      side: BorderSide.none, eccentricity: 0.6),
                                  activeColor: Colors.black,
                                  value: checked3,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checked3 = value!;
                                      if (checked3) {
                                        checked1 = false;
                                        checked2 = false;
                                        pool = 0;
                                      }
                                    });
                                  },
                                ),
                                Text("No Pooling"),
                                Icon(Icons.person_off_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton.icon(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.black),
                          foregroundColor:
                              WidgetStatePropertyAll(Colors.white)),
                      onPressed: () {
                        if (!checked1 && !checked2 && !checked3) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Please select any of the Pooling Options"),
                            duration: Duration(seconds: 1),
                          ));
                        } else {
                          Navigator.pop(context);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contex) => sedan(
                                      name: widget.name,
                                      phone: widget.phone,
                                      source: widget.source,
                                      dest: widget.dest,
                                      time: widget.time,
                                      vehicle: text,
                                      pooling: pool)));
                        }
                      },
                      label: Text('Proceed'),
                      icon: Icon(Icons.forward),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }

  String _1 = "SEDAN 2007";
  String _2 = "ERTIGA 2010";
  String _3 = "INNOVA CRYSTA";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 30,
                      color: Colors.grey,
                      child: InkWell(
                        onTap: () {
                          _showbottomsheet(context, _1);
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              child: Image.asset("assets/img/sedan.jpg"),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      child: Icon(Icons.pin_drop_rounded),
                                    ),
                                    Text("${widget.distance}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      child: Icon(Icons.timer),
                                    ),
                                    Text("${widget.estdtime}")
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 30,
                      color: Colors.grey,
                      child: InkWell(
                        onTap: () {
                          _showbottomsheet(context, _2);
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              child: Image.asset("assets/img/ertiga.jpg"),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      child: Icon(Icons.pin_drop_rounded),
                                    ),
                                    Text("${widget.distance}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      child: Icon(Icons.timer),
                                    ),
                                    Text("${widget.estdtime}")
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 30,
                      color: Colors.grey,
                      child: InkWell(
                        onTap: () {
                          _showbottomsheet(context, _3);
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              child: Image.asset("assets/img/innova.jpg"),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      child: Icon(Icons.pin_drop_rounded),
                                    ),
                                    Text("${widget.distance}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      child: Icon(Icons.timer),
                                    ),
                                    Text("${widget.estdtime}")
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
