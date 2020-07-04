import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class GeorgyAwakeIcon extends StatefulWidget {
  @override
  _GeorgyAwakeIconState createState() => _GeorgyAwakeIconState();

  static void setOpacity(double opacity) {
    _GeorgyAwakeIconState.setAwakeOpacity(opacity);
  }

  static double getOpacity() {
    return _GeorgyAwakeIconState._georgyAwakeOpacity;
  }

//  static bool getNoonNotification() {
//    return _GeorgyAwakeIconState.NoonNotification;
//  }

  static String getWhoWentDownNoon() {
    return _GeorgyAwakeIconState._whoWentDownNoon;
  }
}

class _GeorgyAwakeIconState extends State<GeorgyAwakeIcon> {
  static double _georgyAwakeOpacity = 1;
  static String _whoWentDownNoon = "";
  static String _noonDate = "";
  static String _noonTime = "";
  Timer timer;
  bool awakeTextVisability = false;

//  static bool NoonNotification = false;

  @override
  initState() {
    getAwakeDate();
    getAwakeTime();
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      getAwakeOpacity();
//      getNoonNotification();
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
      margin: EdgeInsets.fromLTRB(
          screenHeight * 0.08, 0, screenHeight * 0.08, screenHeight * 0.01),
      child: GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipOval(
              child: AnimatedOpacity(
                opacity: _georgyAwakeOpacity,
                duration: Duration(milliseconds: 300),
                child: Container(
                  height: screenHeight * 0.33,
                  width: screenHeight * 0.34,
                  child: Image.asset(
                    'images/georgyAwake.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
//              margin: EdgeInsets.fromLTRB(0, screenHeight * 0.12, screenHeight * 0.013, 0),
              child: Center(
                child: Visibility(
                  visible: awakeTextVisability,
                  child: Column(
                    children: <Widget>[
                      Text(
                        _whoWentDownNoon,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.09,
                          fontFamily: 'SpecialFont',
                        ),
                      ),
                      Text(
                        _noonDate,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.05,
                          fontFamily: 'SpecialFont',
                        ),
                      ),
                      Text(
                        _noonTime,
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
          if (_georgyAwakeOpacity == 1.0 &&
              GeorgyHomePage.getPremissionToUse()) {
            Firestore.instance
                .collection('booleans')
                .document('lukAMY1dkyDsuTpdCtZr')
                .updateData({"georgyAwakeOpacity": 0.4});

            Firestore.instance
                .collection('booleans')
                .document('lukAMY1dkyDsuTpdCtZr')
                .updateData(
                    {"whoWentDownNoon": GeorgyHomePage.getDeviceName()});

            Firestore.instance
                .collection('booleans')
                .document('lukAMY1dkyDsuTpdCtZr')
                .updateData({
              "NoonDate": DateTime.now().day.toString() +
                  " / " +
                  DateTime.now().month.toString()
            });

            Firestore.instance
                .collection('booleans')
                .document('lukAMY1dkyDsuTpdCtZr')
                .updateData({
              "NoonTime": DateTime.now().hour.toString() +
                  ":" +
                  DateTime.now().minute.toString()
            });

//            Firestore.instance
//                .collection('booleans')
//                .document('lukAMY1dkyDsuTpdCtZr')
//                .updateData({"NoonNotification": true});
          }
          getAwakeOpacity();
          getAwakeDate();
          getAwakeTime();
        },
      ),
    );
  }

//  String setAwakeTime() {
//    if (_noonDateTime.minute.toInt() < 10) {
//      return _noonDateTime.hour.toString() +
//          ":0" +
//          _noonDateTime.minute.toString();
//    } else {
//      return _noonDateTime.hour.toString() +
//          ":" +
//          _noonDateTime.minute.toString();
//    }
//  }
//
//  String setAwakeDate() {
//    return _noonDateTime.day.toString() +
//        " / " +
//        _noonDateTime.month.toString();
//  }

  Future<void> getAwakeDate() async {
    await Firestore.instance
        .collection('booleans')
        .document('lukAMY1dkyDsuTpdCtZr')
        .get()
        .then((value) {
      for (int i = 0; i < value.data.values.toList().length; i++) {
        if (value.data.keys.toList()[i] == "NoonDate") {
          setState(() {
            _noonDate = value.data.values.toList()[i];
          });
        }
      }
    });
  }

  Future<void> getAwakeTime() async {
    await Firestore.instance
        .collection('booleans')
        .document('lukAMY1dkyDsuTpdCtZr')
        .get()
        .then((value) {
      for (int i = 0; i < value.data.values.toList().length; i++) {
        if (value.data.keys.toList()[i] == "NoonTime") {
          setState(() {
            _noonTime = value.data.values.toList()[i];
          });
        }
      }
    });
  }

  Future<void> getAwakeOpacity() async {
    Firestore.instance
        .collection('booleans')
        .document('lukAMY1dkyDsuTpdCtZr')
        .get()
        .then((value) {
      setState(() {
        for (int i = 0; i < value.data.values.toList().length; i++) {
          if (value.data.keys.toList()[i] == "georgyAwakeOpacity") {
            _georgyAwakeOpacity = value.data.values.toList()[i];
          }

          if (value.data.keys.toList()[i] == "whoWentDownNoon") {
            _whoWentDownNoon = value.data.values.toList()[i];
          }
        }
      });
    });

    if (_georgyAwakeOpacity == 1) {
      awakeTextVisability = false;
    } else if (_georgyAwakeOpacity == 0.4) {
      awakeTextVisability = true;
    }
  }

  static void setAwakeOpacity(double opacity) {
    _georgyAwakeOpacity = opacity;
  }

  static double getOpacity() {
    return _georgyAwakeOpacity;
  }

//  Future<void> getNoonNotification() async {
//    await Firestore.instance
//        .collection('booleans')
//        .document('lukAMY1dkyDsuTpdCtZr')
//        .get()
//        .then((value) {
//      for (int i = 0; i < value.data.values.toList().length; i++) {
//        if (value.data.keys.toList()[i] == "NoonNotification") {
//          NoonNotification = value.data.values.toList()[i];
//        }
//      }
//    });
//  }

}
