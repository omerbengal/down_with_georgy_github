import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/services.dart';
import 'georgyAwakeIcon.dart';
import 'georgyAsleepIcon.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'FirebaseMessagingDemo.dart';

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
//  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

//  var initializationSettingsAndroid;
//  var initializationSettingsIOS;
//  var initializationSettings;

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
    getDeviceNameByID();
    getOmerDeviceID();
    super.initState();
//    initializationSettingsAndroid =
//        new AndroidInitializationSettings('app_icon');
//    initializationSettingsIOS = new IOSInitializationSettings(
//        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//    initializationSettings = new InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
    timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      getDevicesIDToList();
////      getOpacity();
////      _showNotification();
    });
  }

//
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    double screenHeight = (MediaQuery.of(context).size.height - AppBar().preferredSize.height);
    double screenHeight = (MediaQuery.of(context).size.height);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
//      isAllowedToUseApp();
    });

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
                  GeorgyAwakeIcon(),
                  GeorgyAsleepIcon(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.fromLTRB(screenHeight * 0.05,
                              screenHeight * 0.01, screenHeight * 0.05, 0),
                          child: IconButton(
                              iconSize: (MediaQuery.of(context).size.height -
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
                              iconSize: (MediaQuery.of(context).size.height -
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
        var screenHeight = (MediaQuery.of(context).size.height);
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
        var screenHeight = (MediaQuery.of(context).size.height);
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
//            _georgyAwakeOpacity = value.data.values.toList()[1].toDouble();
//            _georgyAsleepOpacity = value.data.values.toList()[0].toDouble();

        GeorgyAwakeIcon.setOpacity(value.data.values.toList()[1].toDouble());
        GeorgyAsleepIcon.setOpacity(value.data.values.toList()[0].toDouble());
      });
    });

//    print("getOpacity Done");
  }

  Future<void> getDeviceID() async {
    deviceID = await DeviceId.getID;
//    DeviceId.getID.then((value) {
//      deviceID = value;
//      print("doneINSIDE1");
//    });
  }

  Future<void> getDeviceNameByID() async {
    await Firestore.instance
        .collection('booleans')
        .document('uIX5KE7Wv07PcoYPOlyJ')
        .get()
        .then((value) {
        for (int i = 0; i < value.data.values.toList().length; i++) {
          if (deviceID == value.data.values.toList()[i]) {
            _deviceNameByID = value.data.keys.toList()[i];
          }
        }
    });
  }

  Future<void> getDevicesIDToList() async {
    await Firestore.instance
        .collection('booleans')
        .document('uIX5KE7Wv07PcoYPOlyJ')
        .get()
        .then((value) {
      setState(() {
        idList.length = value.data.values.toList().length;
        for (int i = 0; i < value.data.values.toList().length; i++) {
          if (deviceID == value.data.values.toList()[i]) {
            _deviceNameByID = value.data.keys.toList()[i];
          }

          idList[i] = value.data.values.toList()[i];
        }
      });
    });
    isAllowedToUseApp();
  }

  void isAllowedToUseApp() {
    for (int i = 0; i < idList.lengtif (deviceID == idList[i]) {h; i++) {

    setState(() {
          _premissionToUse = true;
        });
        break;
      } else {
        setState(() {
          _premissionToUse = false;
        });
      }
    }
//    print("isAllowedToUseApp Done");
  }

  Future<void> refreshFunctions() async {
    await getOpacity();
    await getDevicesIDToList();
  }

  Future<void> getOmerDeviceID() async {
    await Firestore.instance
        .collection('booleans')
        .document('uIX5KE7Wv07PcoYPOlyJ')
        .get()
        .then((value) {
      for (int i = 0; i < value.data.values.toList().length; i++) {
        if (value.data.keys.toList()[i] == "עומר") {
          omerDeviceID = value.data.values.toList()[i];
        }
      }
    });
  }

/////////////////////////////////////////////////////////

//  void _showNotification() async {
//    //מרכזי
//    if (GeorgyAwakeIcon.getNoonNotification()) {
//
//      await Firestore.instance
//          .collection('booleans')
//          .document('lukAMY1dkyDsuTpdCtZr')
//          .get()
//          .then((value) async {
//        for (int i = 0; i < value.data.values.toList().length; i++) {
//          if (value.data.keys.toList()[i] == "whoWentDownNoon") {
//            if (_deviceNameByID != value.data.values.toList()[i]) {
//              await _notification();
//            }
//          }
//        }
//      });
//
////      if(_deviceNameByID != GeorgyAwakeIcon.getWhoWentDownNoon()) {
////        await _notification();
////      }
//
//      await Firestore.instance
//          .collection('booleans')
//          .document('lukAMY1dkyDsuTpdCtZr')
//          .updateData({"NoonNotification": false});
//
//    } else if (GeorgyAsleepIcon.getEveningNotification()) {
//
//      await Firestore.instance
//          .collection('booleans')
//          .document('lukAMY1dkyDsuTpdCtZr')
//          .get()
//          .then((value) async {
//        for (int i = 0; i < value.data.values.toList().length; i++) {
//          if (value.data.keys.toList()[i] == "whoWentDownEvening") {
//            if (_deviceNameByID != value.data.values.toList()[i]) {
//              await _notification();
//            }
//          }
//        }
//      });
//
////    if(_deviceNameByID != GeorgyAsleepIcon.getWhoWentDownEvening()) {
////      await _notification();
////    }
//
//      await Firestore.instance
//          .collection('booleans')
//          .document('lukAMY1dkyDsuTpdCtZr')
//          .updateData({"EveningNotification": false});
//
//    }
//  }
//
//  Future<void> _notification() async {
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        'channelId', 'channelName', 'channelDescription',
//        importance: Importance.Max,
//        priority: Priority.High,
//        ticker: 'test Ticker');
//
//    var iOSChannelSpecifics = IOSNotificationDetails();
//
//    var platformChannelSpecifics = NotificationDetails(
//        androidPlatformChannelSpecifics, iOSChannelSpecifics);
//
//    await flutterLocalNotificationsPlugin.show(0, "ג'ורג'י!",
//        "מישהו ירד עם ג'ורג'י! גלה מי זה!", platformChannelSpecifics,
//        payload: 'test payload');
//  }
//
//  Future<void> _resetNotification() async {
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        'channelId', 'channelName', 'channelDescription',
//        importance: Importance.Max,
//        priority: Priority.High,
//        ticker: 'test Ticker');
//
//    var iOSChannelSpecifics = IOSNotificationDetails();
//
//    var platformChannelSpecifics = NotificationDetails(
//        androidPlatformChannelSpecifics, iOSChannelSpecifics);
//
//    await flutterLocalNotificationsPlugin.show(
//        0, "איפוס", "צריך לאפס את הנתונים!!", platformChannelSpecifics,
//        payload: 'test payload');
//  }
//
//  Future onDidReceiveLocalNotification(
//      int id, String title, String body, String payload) async {
//    await showDialog(
//        context: context,
//        builder: (BuildContext context) => CupertinoAlertDialog(
//              title: Text(title),
//              content: Text(body),
//              actions: <Widget>[
//                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!להבין מה זה
//                CupertinoDialogAction(
//                  isDefaultAction: true,
//                  child: Text("Ok"),
//                  onPressed: () {
//                    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!צריך להוריד את החלק הזה - לא עובד
//                    if (_deviceNameByID == "עומר") {
//                      Firestore.instance
//                          .collection('booleans')
//                          .document('lukAMY1dkyDsuTpdCtZr')
//                          .updateData({"georgyAwakeOpacity": 1.0});
//                      Firestore.instance
//                          .collection('booleans')
//                          .document('lukAMY1dkyDsuTpdCtZr')
//                          .updateData({"georgyAsleepOpacity": 1.0});
//                    }
//                  },
//                )
//              ],
//            ));
//  }
//
//  Future onSelectNotification(String payload) async {
////    Firestore.instance.collection('booleans').document('lukAMY1dkyDsuTpdCtZr').updateData({"georgyAwakeOpacity": 1.0});
//
//  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!צריך להוריד את החלק הזה - לא עובד
//    if (_deviceNameByID == "עומר") {
//      Firestore.instance
//          .collection('booleans')
//          .document('lukAMY1dkyDsuTpdCtZr')
//          .updateData({"georgyAwakeOpacity": 1.0});
//      Firestore.instance
//          .collection('booleans')
//          .document('lukAMY1dkyDsuTpdCtZr')
//          .updateData({"georgyAsleepOpacity": 1.0});
//    }
//  }
}
