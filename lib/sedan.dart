import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'final_page.dart';

class sedan extends StatefulWidget {
  final String name;
  final String phone;
  final String source;
  final String dest;

  final DateTime time;
  final String vehicle;
  final int pooling;

  const sedan(
      {super.key,
      required this.name,
      required this.phone,
      required this.source,
      required this.dest,
      required this.time,
      required this.vehicle,
      required this.pooling});

  @override
  State<sedan> createState() => _sedanState();
}

class _sedanState extends State<sedan> {
  bool checked1 = true;
  bool checked2 = false;
  bool checked3 = false;
  int pool = 2;
  /*Future<void> Store() async {
    if (checked1 == true) {
      pool = 2;
    } else if (checked2 == true)
      pool = 1;
    else
      pool = 0;
    try {
      await FirebaseFirestore.instance
          .collection('DATA')
          .doc('${widget.name}')
          .set({
        'name': widget.name,
        'phone': widget.phone,
        'source': widget.source,
        'location': widget.dest,
        'date': '${widget.date.toLocal()}',
        'time': '${widget.tiRme}',
        'vehicle': widget.vehicle,
        'pool_option': pool
      });
    } catch (e) {
      print('Error Booking.Please try Booking later .Error code $e');
    }
  }*/

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> Store() async {
    _firestore.collection('DATA');
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('DATA').doc(widget.phone);
    DocumentSnapshot documentSnapshot = await userDoc.get();
    if (!documentSnapshot.exists) {
      await userDoc.set({
        'Temp Name': widget.name,
        'Phone Number': widget.phone,
        'Bookings': 0,
      });
      await addbooking(userDoc, documentSnapshot);
    } else if (documentSnapshot.exists &&
        documentSnapshot.get('Bookings') <= 2) {
      //only two bookings
      await addbooking(userDoc, documentSnapshot);
    } else if (documentSnapshot.exists &&
        documentSnapshot.get('Bookings') > 2) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error Booking'),
              content: Text(
                  "You have reached the maximum booking limit. Please wait for current bookings to complete or cancel an existing one to proceed."),
              actions: [
                Center(
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("OK")),
                )
              ],
            );
          });
    }
  }

  String? a, b, c;
  @override
  void initState() {
    super.initState();

    a = widget.time.hour > 12
        ? (widget.time.hour - 12).toString()
        : widget.time.hour.toString();
    b = widget.time.minute.toString();
    c = widget.time.hour >= 12 ? 'PM' : "AM";
  }

  Future<void> addbooking(
      DocumentReference userDoc, DocumentSnapshot documentSnapshot) async {
    try {
      int count = documentSnapshot.get('Bookings');
      count += 1;
      await userDoc.update({
        'Bookings': count,
      });

      CollectionReference bookings = userDoc.collection('bookings');
      await bookings.add({
        'source': widget.source,
        'location': widget.dest,
        'time': widget.time.toString(),
        'vehicle': widget.vehicle,
        'pool_option': widget.pooling,
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => final_page(
                    name: widget.name,
                    phone: widget.phone,
                    source: widget.source,
                    dest: widget.dest,
                    time: widget.time,
                    vehicle: widget.vehicle,
                    pool: pool,
                  )),
          (Route<dynamic> route) => false);
    } catch (e) {
      print('Error Booking : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 5),
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ClipRRect(
                                child: Image.asset("assets/img/taxi (3).png")),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                              child: Column(
                                children: [
                                  Text(
                                    "${widget.vehicle}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          decoration: BoxDecoration(
                              //  border: Border.all(color: Colors.black),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "BOOKING DETAILS",
                                      style: TextStyle(fontSize: 25),
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 3),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "DATE : ",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          // Text(":"),
                                          // const SizedBox(
                                          //   height: 10,
                                          // ),
                                          Text(
                                            "${widget.time}".split(' ')[0],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "TIME :",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          // Text(":"),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "${a}:${b} ${c}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              "SOURCE :   ",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          // const SizedBox(
                                          //   height: 10,
                                          // ),
                                          // Text(":"),
                                          // const SizedBox(
                                          //   height: 10,
                                          // ),
                                          Flexible(
                                              child: Text(
                                            "${widget.source}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              "DESTINATION : ",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          // const SizedBox(
                                          //   height: 10,
                                          // ),
                                          // Text(":"),
                                          // const SizedBox(
                                          //   height: 10,
                                          // ),
                                          Flexible(
                                            child: Text(
                                              "${widget.dest},",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "POOL SIZE : ",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          // Text(":"),
                                          // const SizedBox(
                                          //   height: 10,
                                          // ),
                                          Text(
                                            "${widget.pooling}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                Container(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.white),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.black)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Go Back'),
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                foregroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.white),
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.black)),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Confirmation"),
                                                    content: const Text(
                                                        "Confirm Booking?"),
                                                    actions: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          TextButton(
                                                              style: ButtonStyle(
                                                                  foregroundColor:
                                                                      WidgetStatePropertyAll(
                                                                          Colors
                                                                              .white),
                                                                  backgroundColor:
                                                                      WidgetStatePropertyAll(
                                                                          Colors
                                                                              .black)),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  "No")),
                                                          TextButton(
                                                              style: ButtonStyle(
                                                                  backgroundColor:
                                                                      WidgetStatePropertyAll(
                                                                          Colors
                                                                              .black),
                                                                  foregroundColor:
                                                                      WidgetStatePropertyAll(
                                                                          Colors
                                                                              .white)),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                Store();
                                                              },
                                                              child: const Text(
                                                                  "Yes")),
                                                        ],
                                                      )
                                                    ],
                                                  );
                                                },
                                                barrierDismissible: true,
                                              );
                                            },
                                            child: const Text('Continue'))
                                      ]),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
