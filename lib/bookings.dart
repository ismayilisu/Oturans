import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class bookings extends StatefulWidget {
  final String phone;

  const bookings({super.key, required this.phone});

  @override
  State<bookings> createState() => _bookingsState();
}

class _bookingsState extends State<bookings> {
  final FirebaseFirestore _instance1 = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    //_collectbookings();
  }

  Future<List<Map<String, dynamic>>> _collectbookings() async {
    List<Map<String, dynamic>> documentDetails = [];

    List<String> documentIds = [widget.phone];
    for (var docId in documentIds) {
      DocumentReference documentref = _instance1.collection('DATA').doc(docId);
      DocumentSnapshot documentsnap = await documentref.get();
      if (documentsnap.exists) {
        //go to subcolletino reference
        CollectionReference subcollectionref =
            documentref.collection('bookings');
        QuerySnapshot subdocuments = await subcollectionref.get();
        //  print(subdocuments);
        for (var doc in subdocuments.docs) {
          Map<String, dynamic> info = doc.data() as Map<String, dynamic>;
          // print(info);

          bool k = (DateTime.now()).isBefore(DateTime.parse(info['time']));
          (DateTime.parse(info['time'])).isBefore(DateTime.now());
          // print(now);

          if (k == true) {
            documentDetails.add({
              'subDocId': doc.id,
              'subDocData': doc.data(),
            });
          } else if (!k) {
            //delete the data from

            DocumentReference docref = await subcollectionref.doc(doc.id);
            await docref.delete();
            int count = documentsnap['Bookings'];
            count -= 1;
            documentref.update({
              'Bookings': count,
            });
          }
        }
      }
    }
    //print(documentDetails);
    return documentDetails;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("BOOKINGS"),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _collectbookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error : ${snapshot.error}"),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No Bookings Available"));
            }

            var bookings = snapshot.data!;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                var booking = bookings[index];
                return ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Cancel Booking?"),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("NO"),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                  ),
                                  onPressed: () async {
                                    try {
                                      Navigator.pop(context);
                                      DocumentReference del = FirebaseFirestore
                                          .instance
                                          .collection('DATA')
                                          .doc(widget.phone)
                                          .collection('bookings')
                                          .doc(booking['subDocId']);
                                      await del.delete();
                                      DocumentReference doc1 =
                                          await FirebaseFirestore.instance
                                              .collection('DATA')
                                              .doc(widget.phone);
                                      DocumentSnapshot snap1 = await doc1.get();
                                      int count = snap1['Bookings'];
                                      count -= 1;
                                      doc1.update({
                                        'Bookings': count,
                                      });
                                      bookings.removeAt(index);

                                      setState(() {});
                                    } catch (e) {
                                      print("Error deleting booking: $e");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Failed to delete booking")),
                                      );
                                    }
                                  },
                                  child: Text("YES"),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  title: Text(
                      "   ${booking["subDocData"]['time']}                              "),
                  subtitle: Text(
                    "${booking["subDocData"]['source']} To ${booking["subDocData"]['location']}",
                  ),
                  trailing: Text(
                    "${booking['subDocData']['vehicle']} ${booking['subDocData']['pool_option']}",
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
