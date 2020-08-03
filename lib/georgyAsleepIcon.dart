import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class GeorgyAsleepIcon extends StatefulWidget {
  @override
  _GeorgyAsleepIconState createState() => _GeorgyAsleepIconState();
}

class _GeorgyAsleepIconState extends State<GeorgyAsleepIcon> {
  Timer timer;

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery.of(context).size.height);

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('booleans').snapshots(),
      builder: (context, snapshot) {

        if(!snapshot.hasData) {
          return Text('Loading...');
        }

        return Container(
          margin: EdgeInsets.fromLTRB(screenHeight * 0.08, screenHeight * 0.01,
              screenHeight * 0.08, 0),
          child: GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ClipOval(
                  child: AnimatedOpacity(
                    opacity: snapshot.data.documents[1]['Opacity'].toDouble(),
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      height: screenHeight * 0.33,
                      width: screenHeight * 0.34,
                      child: Image.asset(
                        'images/georgyAsleep.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
//              margin: EdgeInsets.fromLTRB(0, screenHeight * 0.12, screenHeight * 0.013, 0),
                  child: Center(
                    child: Visibility(
                      visible: snapshot.data.documents[1]['Opacity'].toDouble() == 1 ? false : true,
                      child: Column(
                        children: <Widget>[
                          Text(
                            snapshot.data.documents[1]['WhoWentDown'],
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.09,
                              fontFamily: 'SpecialFont',
                            ),
                          ),
                          Text(
                            snapshot.data.documents[1]['Date'],
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.05,
                              fontFamily: 'SpecialFont',
                            ),
                          ),
                          Text(
                            snapshot.data.documents[1]['Time'],
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.05,
                              fontFamily: 'SpecialFont',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              if (snapshot.data.documents[1]['Opacity'].toDouble() == 1.0 &&
                  snapshot.data.documents[4].data.containsValue(GeorgyHomePage.getDeviceId())) {
                Firestore.instance
                    .collection('booleans')
                    .document('GeorgyEvening')
                    .updateData({"Opacity": 0.4});

                Firestore.instance
                    .collection('booleans')
                    .document('GeorgyEvening')
                    .updateData(
                    {"WhoWentDown": snapshot.data.documents[4].data.keys.toList().firstWhere((element) => snapshot.data.documents[4].data[element] == GeorgyHomePage.getDeviceId())
                    });

                Firestore.instance
                    .collection('booleans')
                    .document('GeorgyEvening')
                    .updateData({
                  "Date": DateTime.now().day.toString() +
                      " / " +
                      DateTime.now().month.toString()
                });

                Firestore.instance
                    .collection('booleans')
                    .document('GeorgyEvening')
                    .updateData({"Time": setEveningTime()});
              }
            },
          ),
        );
      }
    );
  }

  String setEveningTime() {
    if (DateTime.now().minute < 10) {
      return DateTime.now().hour.toString() +
          ":0" +
          DateTime.now().minute.toString();
    } else {
      return DateTime.now().hour.toString() +
          ":" +
          DateTime.now().minute.toString();
    }
  }

}
