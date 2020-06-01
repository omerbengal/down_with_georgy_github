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

  static double _georgyAsleepOpacity = 1;
  static String _whoWentDownEvening = "";
  Timer timer;
  bool AsleepTextVisability = false;
//  static bool EveningNotification = false;

  @override
  initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      getAsleepOpacity();
//      getEveningNotification();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    double screenHeight = (MediaQuery
        .of(context)
        .size
        .height);

    return Container(
      margin: EdgeInsets.fromLTRB(
          screenHeight * 0.08,
          screenHeight * 0.025,
          screenHeight * 0.08,
          screenHeight * 0.022),
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
                  child: Text(
                    _whoWentDownEvening,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenHeight * 0.06, fontFamily: 'SpecialFont',),
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          if (_georgyAsleepOpacity == 1.0 && GeorgyHomePage.getPremissionToUse()) {
            Firestore.instance
                .collection('booleans')
                .document('lukAMY1dkyDsuTpdCtZr')
                .updateData({"georgyAsleepOpacity": 0.4});

            Firestore.instance
                .collection('booleans')
                .document('lukAMY1dkyDsuTpdCtZr')
                .updateData({"whoWentDownEvening": GeorgyHomePage.getDeviceName()});

//            Firestore.instance
//                .collection('booleans')
//                .document('lukAMY1dkyDsuTpdCtZr')
//                .updateData({"EveningNotification": true});
          }
          getAsleepOpacity();
        },
      ),
    );
  }


  Future<void> getAsleepOpacity() async {
    Firestore.instance
        .collection('booleans')
        .document('lukAMY1dkyDsuTpdCtZr')
        .get()
        .then((value) {
      setState(() {
        for (int i = 0; i < value.data.values.toList().length; i++) {
          if (value.data.keys.toList()[i] == "georgyAsleepOpacity") {
            _georgyAsleepOpacity = value.data.values.toList()[i];
          }

          if (value.data.keys.toList()[i] == "whoWentDownEvening") {
            _whoWentDownEvening = value.data.values.toList()[i];
          }
        }
      });
    });

    if(_georgyAsleepOpacity == 1) {
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


//  Future<void> getEveningNotification() async {
//    await Firestore.instance
//        .collection('booleans')
//        .document('lukAMY1dkyDsuTpdCtZr')
//        .get()
//        .then((value) {
//      for (int i = 0; i < value.data.values.toList().length; i++) {
//        if (value.data.keys.toList()[i] == "EveningNotification") {
//          EveningNotification = value.data.values.toList()[i];
//        }
//      }
//    });
//  }

}

