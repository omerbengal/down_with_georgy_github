import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/services.dart';
import 'georgyAwakeIcon.dart';
import 'georgyAsleepIcon.dart';

class GeorgyHomePage extends StatefulWidget {
  @override
  _GeorgyHomePageState createState() => _GeorgyHomePageState();

  static bool getPremissionToUse() {
    return _GeorgyHomePageState._premissionToUse;
  }

  static String getDeviceName() {
    return _GeorgyHomePageState._deviceNameByID;
  }
}

class _GeorgyHomePageState extends State<GeorgyHomePage> {

  bool _premissionToReset = false;
  var dbForUsing;
  static bool _premissionToUse = false;
  String deviceID = "";
  List<String> idList = new List();
  Timer timer;
  static String _deviceNameByID;
  String omerDeviceID;

  @override
  initState() {
    getDeviceID();
    getDevicesIDFromFirebase();
    getOmerDviceID();
    super.initState();
  }

//  @override
//  void dispose() {
//    timer?.cancel();
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery
        .of(context)
        .size
        .height);
    double screenwidth = (MediaQuery
        .of(context)
        .size
        .width);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

//    WidgetsBinding.instance.addPostFrameCallback((_) {
////      isAllowedToUseApp();
//    });

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(
            "ג׳ורג׳י!",
            style: TextStyle(
              fontSize: screenHeight * 0.05,
            ),
            textDirection: TextDirection.rtl,
          ),
          onLongPress: () {
            setState(() {
              _premissionToReset = !_premissionToReset;
            });
          },
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (BuildContext context) {
          return RefreshIndicator(
            onRefresh: refreshFunctions,
            child: Container(
              decoration: BoxDecoration(color: Colors.blue[100]),
              child: ListView(
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          0, screenHeight * 0.01, 0, screenHeight * 0.01),
                      child: Text("היום: " +
                          DateTime
                              .now()
                              .month
                              .toString() +
                          " / " +
                          DateTime
                              .now()
                              .day
                              .toString(),
                        style: TextStyle(
                          fontSize: screenHeight / 25,
                          fontFamily: 'SpecialFont',
                        ),
                        textDirection: TextDirection.rtl,),
                    ),
                  ),
                  GeorgyAwakeIcon(),
                  GeorgyAsleepIcon(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.fromLTRB(screenHeight * 0.05,
                              screenHeight * 0.01, screenHeight * 0.05, 0),
                          child: IconButton(
                              iconSize: (MediaQuery
                                  .of(context)
                                  .size
                                  .height -
                                  AppBar().preferredSize.height) *
                                  0.055,
                              icon: Icon(Icons.add_to_home_screen),
                              onPressed: () {
                                Clipboard.setData(
                                    new ClipboardData(text: deviceID));
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "הID שלך *הועתק*. אם האפליקציה לא עובדת יש לשלוח את הID לעומר בוואטסאפ (ללכת לוואטסאפ ולהדביק).",
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: screenHeight * 0.018),
                                    ),
                                    duration: const Duration(seconds: 6),
                                  ),
                                );
                              })),
                      Container(
                          margin: EdgeInsets.fromLTRB(screenHeight * 0.05,
                              screenHeight * 0.01, screenHeight * 0.05, 0),
                          child: IconButton(
                              iconSize: (MediaQuery
                                  .of(context)
                                  .size
                                  .height -
                                  AppBar().preferredSize.height) *
                                  0.055,
                              icon: Icon(Icons.cancel),
                              onPressed: _premissionToUse
                                  ? () {
                                if (_premissionToReset ||
                                    deviceID == omerDeviceID) {
                                  if (GeorgyAwakeIcon.getOpacity() ==
                                      0.4 ||
                                      GeorgyAsleepIcon.getOpacity() ==
                                          0.4) {
                                    _thingsToCancelDialog();
                                  } else {
                                    _noThingsToDoDialog();
                                  }
                                } else {
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _deviceNameByID +
                                            ', '
                                                'אין לך הרשאות לבטל ירידה... נא לפנות לעומר בנגל המלך!'
                                                ' (או למצוא את הEASTER EGG)',
                                        textDirection: TextDirection.rtl,
                                      ),
                                      duration:
                                      const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                                  : null)),
                    ],
                  )
                ],
              ),
              alignment: Alignment.center,
            ),
          );
        },
      ),
    );
  }

  void _thingsToCancelDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        var screenHeight = (MediaQuery
            .of(context)
            .size
            .height);
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("מה לבטל?",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: screenHeight * 0.04)),
            ],
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("איזה ירידה תרצה לבטל?",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: screenHeight * 0.025)),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            Container(
              margin: EdgeInsets.only(right: screenHeight * 0.00001),
              child: FlatButton(
                padding: EdgeInsets.fromLTRB(
                    screenHeight * 0.045,
                    screenHeight * 0.02,
                    screenHeight * 0.045,
                    screenHeight * 0.02),
                child: Text("ערב",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: screenHeight * 0.04)),
                onPressed: () {
                  setState(() {
                    Firestore.instance
                        .collection('booleans')
                        .document('lukAMY1dkyDsuTpdCtZr')
                        .updateData({"georgyAsleepOpacity": 1.0});
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: screenHeight * 0.001),
              child: FlatButton(
                padding: EdgeInsets.fromLTRB(
                    screenHeight * 0.03,
                    screenHeight * 0.02,
                    screenHeight * 0.03,
                    screenHeight * 0.02),
                child: Text("צהריים",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: screenHeight * 0.04)),
                onPressed: () {
                  setState(() {
                    Firestore.instance
                        .collection('booleans')
                        .document('lukAMY1dkyDsuTpdCtZr')
                        .updateData({"georgyAwakeOpacity": 1.0});
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _noThingsToDoDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        var screenHeight = (MediaQuery
            .of(context)
            .size
            .height);
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("אין שום דבר לבטל!",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: screenHeight * 0.040)),
            ],
          ),
          content: Container(
            child: Text(
                "אף אחד לא ירד איתו, לא בצהריים ולא בערב, אין מה לבטל...",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: screenHeight * 0.023)),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            Container(
              margin: EdgeInsets.only(right: screenHeight * 0.10),
              child: FlatButton(
                padding: EdgeInsets.fromLTRB(
                    screenHeight * 0.045,
                    screenHeight * 0.02,
                    screenHeight * 0.045,
                    screenHeight * 0.02),
                child: Text("ביטול",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: screenHeight * 0.044)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> getOpacity() async {
    Firestore.instance
        .collection('booleans')
        .document('lukAMY1dkyDsuTpdCtZr')
        .get()
        .then((value) {
      setState(() {
        GeorgyAwakeIcon.setOpacity(value.data.values.toList()[1].toDouble());
        GeorgyAsleepIcon.setOpacity(value.data.values.toList()[0].toDouble());
      });
    });
  }

  Future<void> getDeviceID() async {
    deviceID = await DeviceId.getID;
  }

  Future<void> getDevicesIDFromFirebase() async {
    await Firestore.instance
        .collection('booleans')
        .document('uIX5KE7Wv07PcoYPOlyJ')
        .get()
        .then((value) {
      setState(() {
        idList.length = value.data.values
            .toList()
            .length;
        for (int i = 0; i < value.data.values
            .toList()
            .length; i++) {
          if (deviceID == value.data.values.toList()[i]) {
            _deviceNameByID = value.data.keys.toList()[i];
          }

          idList[i] = value.data.values.toList()[i];
        }
      });
      isAllowedToUseApp();
    });
  }

  void isAllowedToUseApp() {
    for (int i = 0; i < idList.length; i++) {
      if (deviceID == idList[i]) {
        _premissionToUse = true;
        break;
      }
    }
  }

  Future<void> refreshFunctions() async {
    await getOpacity();
    await getDevicesIDFromFirebase();
    await getOmerDviceID();
  }

  Future<void> getOmerDviceID() async {
    await Firestore.instance
        .collection('booleans')
        .document('uIX5KE7Wv07PcoYPOlyJ')
        .get()
        .then((value) {
      for (int i = 0; i < value.data.values
          .toList()
          .length; i++) {
        if (value.data.keys.toList()[i] == "עומר") {
          omerDeviceID = value.data.values.toList()[i];
        }
      }
    });
  }
}