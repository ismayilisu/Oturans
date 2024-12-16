import 'package:flutter/material.dart';

import 'location.dart';

class final_page extends StatefulWidget {
  final String name;
  final String phone;
  final String source;
  final String dest;

  final DateTime time;
  final String vehicle;
  final int pool;

  const final_page(
      {super.key,
      required this.name,
      required this.phone,
      required this.source,
      required this.dest,
      required this.time,
      required this.vehicle,
      required this.pool});

  @override
  State<final_page> createState() => _final_pageState();
}

class _final_pageState extends State<final_page> {
  String? date;
  String kmap = '';
  String? a, b, c;
  @override
  void initState() {
    super.initState();
    date = widget.time.toString().split(' ')[0];

    a = widget.time.hour > 12
        ? (widget.time.hour - 12).toString()
        : widget.time.hour.toString();
    b = widget.time.minute.toString();
    c = widget.time.hour >= 12 ? 'PM' : "AM";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Column(
                children: [
                  Container(
                    height: 250,
                    child: Image.asset('assets/img/checked.png'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Container(
                      child: const Text(
                        'Thank you for your booking request! '
                        'We’ll get in touch with you shortly.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Booking Details',
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup Date : $date',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text('Pickup Time :  ${a}:${b} ${c}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Pickup Location : ${widget.source}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Drop Location :  ${widget.dest}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Vehicle :  ${widget.vehicle}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ButtonStyle(
                              foregroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.black)),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => location(
                                          name: widget.name,
                                          phonenumber: widget.phone,
                                        )),
                                (Route<dynamic> route) => false);
                          },
                          label: const Text("HOME"),
                          icon: const Icon(Icons.home_filled),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
