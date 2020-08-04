import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/services.dart';
import 'georgyAwakeIcon.dart';
import 'georgyAsleepIcon.dart';
import 'package:share/share.dart';
import 'ParkPage.dart';

class GeorgyHomePage extends StatefulWidget {
  @override
  _GeorgyHomePageState createState() => _GeorgyHomePageState();

  static String getDeviceId() {
    return _GeorgyHomePageState.deviceID;
  }
}

class _GeorgyHomePageState extends State<GeorgyHomePage> {

  static int _selectedPage = 0;
  bool _premissionToReset = false;
  static String deviceID = "";
  PageController controller = new PageController();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  String deviceToken = '';

  @override
  initState() {
    refreshActions();
    super.initState();
    _fcm.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true)
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery
        .of(context)
        .size
        .height);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(
            "משפחת בנגל 🙌🏻",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('booleans').snapshots(),
        builder: (context, snapshot) {

          if(!snapshot.hasData) {
            return Text('Loading...');
          }

          return PageView(
            onPageChanged: (index) {
              setState(() {
                _selectedPage = index;
              });
            },
            controller: controller,
            children: <Widget>[
              RefreshIndicator(
                    onRefresh: refreshActions,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blue[100]),
                      child: ListView(
                        children: <Widget>[
                          Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                  0, screenHeight * 0.01, 0, 0),
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
                                      0, screenHeight * 0.05, 0),
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
                                              "מסך שיתוף הולך להיפתח - לשלוח לעומר בוואטסאפ",
                                              textDirection: TextDirection.rtl,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: screenHeight * 0.018),
                                            ),
                                            duration: const Duration(seconds: 6),
                                          ),
                                        );
                                        new Timer(const Duration(seconds: 6), () => Share.share("deviceID: " + deviceID + "\nFCMToken: " + deviceToken));
                                      })),
                              Container(
                                  margin: EdgeInsets.fromLTRB(screenHeight * 0.05,
                                      0, screenHeight * 0.05, 0),
                                  child: IconButton(
                                      iconSize: (MediaQuery
                                          .of(context)
                                          .size
                                          .height -
                                          AppBar().preferredSize.height) *
                                          0.055,
                                      icon: Icon(Icons.cancel),
                                      onPressed: snapshot.data.documents[4].data.containsValue(deviceID)
                                          ? () {
                                        if (_premissionToReset ||
                                            deviceID == snapshot.data.documents[4]['עומר']) {
                                          if (snapshot.data.documents[2]['Opacity'].toDouble() ==
                                              0.4 ||
                                              snapshot.data.documents[1]['Opacity'].toDouble() ==
                                                  0.4) {
                                            _thingsToCancelDialog();
                                          } else {
                                            _noThingsToDoDialog();
                                          }
                                        } else {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                snapshot.data.documents[4].data.keys.toList().firstWhere((element) => snapshot.data.documents[4].data[element] == deviceID) +
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
                  ),
              ParkPage(),
            ],
          );
        }
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.pets), title: Text("ג'ורג'י")),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), title: Text("חנייה")),
        ],
        currentIndex: _selectedPage,
        onTap: (index) {
          setState(() {
            _selectedPage = index;
            controller.animateToPage(_selectedPage, duration: Duration(milliseconds: 750), curve: Curves.linearToEaseOut);
          });
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
                        .document('GeorgyEvening')
                        .updateData({"Opacity": 1.0});
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
                        .document('GeorgyNoon')
                        .updateData({"Opacity": 1.0});
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

  Future<void> refreshActions() async {
    deviceID = await DeviceId.getID;
    deviceToken = await _fcm.getToken();
  }
}