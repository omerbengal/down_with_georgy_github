import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class GeorgyAsleepIcon extends StatefulWidget {
  @override
  _GeorgyAsleepIconState createState() => _GeorgyAsleepIconState();

  static void setOpacity(double opacity) {
    _GeorgyAsleepIconState.setAsleepOpacity(opacity);
  }

  static double getOpacity() {
    return _GeorgyAsleepIconState._georgyAsleepOpacity;
  }

//  static bool getEveningNotification() {
//    return _GeorgyAsleepIconState.EveningNotification;
//  }

  static String getWhoWentDownEvening() {
    return _GeorgyAsleepIconState._whoWentDownEvening;
  }
}

class _GeorgyAsleepIconState extends State<GeorgyAsleepIcon> {
  static double _georgyAsleepOpacity = 1.0;
  static String _whoWentDownEvening = "";
  static String _eveningDate = "";
  static String _eveningTime = "";
  Timer timer;
  bool AsleepTextVisability = false;

//  static bool EveningNotification = false;

  @override
  initState() {
    getAsleepOpacity();
    getAsleepDate();
    getAsleepTime();
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {

      if(GeorgyHomePage.getCurrentPage() == 0) {
        getAsleepOpacity();
        getAsleepDate();
        getAsleepTime();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery.of(context).size.height);

    return Container(
      margin: EdgeInsets.fromLTRB(screenHeight * 0.08, screenHeight * 0.01,
          screenHeight * 0.08, 0),
      child: GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipOval(
              child: AnimatedOpacity(
                opacity: _georgyAsleepOpacity,
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
                  visible: AsleepTextVisability,
                  child: Column(
                    children: <Widget>[
                      Text(
                        _whoWentDownEvening,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.09,
                          fontFamily: 'SpecialFont',
                        ),
                      ),
                      Text(
                        _eveningDate,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.05,
                          fontFamily: 'SpecialFont',
                        ),
                      ),
                      Text(
                        _eveningTime,
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
          if (_georgyAsleepOpacity == 1.0 &&
              GeorgyHomePage.getPremissionToUse()) {
            Firestore.instance
                .collection('booleans')
                .document('GeorgyEvening')
                .updateData({"Opacity": 0.4});

            Firestore.instance
                .collection('booleans')
                .document('GeorgyEvening')
                .updateData(
                {"WhoWentDown": GeorgyHomePage.getDeviceName()});

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

//            Firestore.instance
//                .collection('booleans')
//                .document('lukAMY1dkyDsuTpdCtZr')
//                .updateData({"EveningNotification": true});
          }
          getAsleepOpacity();
          getAsleepDate();
          getAsleepTime();
        },
      ),
    );
  }

//  String setAsleepTime() {
//    if (_eveningDateTime.minute.toInt() < 10) {
//      return _eveningDateTime.hour.toString() +
//          ":0" +
//          _eveningDateTime.minute.toString();
//    } else {
//      return _eveningDateTime.hour.toString() +
//          ":" +
//          _eveningDateTime.minute.toString();
//    }
//  }
//
//  String setAsleepDate() {
//    return _eveningDateTime.day.toString() +
//        " / " +
//        _eveningDateTime.month.toString();
//  }

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

  Future<void> getAsleepDate() async {
    await Firestore.instance
        .collection('booleans')
        .document('GeorgyEvening')
        .get()
        .then((value) {
      for (int i = 0; i < value.data.values.toList().length; i++) {
        if (value.data.keys.toList()[i] == "Date") {
          setState(() {
            _eveningDate = value.data.values.toList()[i];
          });
        }
      }
    });
  }

  Future<void> getAsleepTime() async {
    await Firestore.instance
        .collection('booleans')
        .document('GeorgyEvening')
        .get()
        .then((value) {
      for (int i = 0; i < value.data.values.toList().length; i++) {
        if (value.data.keys.toList()[i] == "Time") {
          setState(() {
            _eveningTime = value.data.values.toList()[i];
          });
        }
      }
    });
  }

  Future<void> getAsleepOpacity() async {
    Firestore.instance
        .collection('booleans')
        .document('GeorgyEvening')
        .get()
        .then((value) {

        for (int i = 0; i < value.data.values.toList().length; i++) {
          if (value.data.keys.toList()[i] == "Opacity") {
            setState(() {
              _georgyAsleepOpacity = value.data.values.toList()[i].toDouble();
            });
          }

          if (value.data.keys.toList()[i] == "WhoWentDown") {
            setState(() {
              _whoWentDownEvening = value.data.values.toList()[i];
            });
          }
        }
      });

    if (_georgyAsleepOpacity == 1) {
      AsleepTextVisability = false;
    } else if (_georgyAsleepOpacity == 0.4) {
      AsleepTextVisability = true;
    }
  }

  static void setAsleepOpacity(double opacity) {
    _georgyAsleepOpacity = opacity;
  }

  static double getOpacity() {
    return _georgyAsleepOpacity;
  }
}
