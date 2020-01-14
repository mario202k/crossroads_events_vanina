import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:badges/badges.dart';
import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossroads_events/screens/billet.dart';
import 'package:crossroads_events/screens/chat.dart';
import 'package:crossroads_events/screens/screens.dart';
import 'package:crossroads_events/services/auth.dart';
import 'package:crossroads_events/services/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

class BaseScreen extends StatefulWidget {
  final titles = ['Home', 'Chat', 'Billets', 'Profile'];
  final colors = [Colors.red, Colors.purple, Colors.teal, Colors.green];
  final icons = [
    FontAwesomeIcons.home,
    FontAwesomeIcons.comments,
    FontAwesomeIcons.ticketAlt,
    FontAwesomeIcons.user
  ];

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class BooModel extends Model {
  bool isOpen = false;

  bool get counter => isOpen;

  void change(bool b) {
    // First, increment the counter
    isOpen = b;

    // Then notify all the listeners.
    notifyListeners();
  }
}

class _BaseScreenState extends State<BaseScreen> with TickerProviderStateMixin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  Stream msgNonLu;
  BooModel _booModel = BooModel();

  PageController _pageController;
  MenuPositionController _menuPositionController;
  bool userPageDragging = false;

  bool _swipe = true;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.static;
  double _offset = 0.4;
  double _scale = 0.9;
  double _borderRadius = 50;
  Color currentColor = Colors.black54;
  double _dragUpdate = 0;

  final AuthService _auth = AuthService();

  static AudioCache player = AudioCache();



  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  @override
  void initState() {
    registerNotification();
    configLocalNotification();
    _menuPositionController = MenuPositionController(initPosition: 0);

    _pageController =
        PageController(initialPage: 0, keepPage: false, viewportFraction: 1.0);
    _pageController.addListener(handlePageChange);

    super.initState();
  }

  @override
  void dispose() {
//    if (_pageController != null) _pageController.dispose();
//    if (_menuPositionController != null) _menuPositionController.dispose();
    super.dispose();
  }

  void registerNotification() {
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        accuserDeReception(message);

        //showNotification(message);

        //Fluttertoast.showToast(msg: '')

//        showDialog(
//          context: context,
//          builder: (context) => AlertDialog(
//            content: ListTile(
//              title: Text(message['notification']['title']),
//              subtitle: Text(message['notification']['body']),
//            ),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('Ok'),
//                onPressed: () => Navigator.of(context).pop(),
//              ),
//            ],
//          ),
//        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch');
        accuserDeReception(message);
        showNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume');
        accuserDeReception(message);
        showNotification(message);
      },
    );
  }

  void accuserDeReception(Map<String, dynamic> message) {
    Firestore.instance
        .collection('chats')
        .document(message['data']['chatId'].toString().toString()) //chatId
        .collection('messages')
        .where('state', isEqualTo: 0)
        .getDocuments()
        .then((docs) {
      docs.documents.forEach((doc) {
        Firestore.instance
            .collection('chats')
            .document(message['data']['chatId'].toString().toString())
            .collection('messages')
            .document(doc.documentID)
            .updateData({'state': 1}); //message reçu
      });
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.vaninamario.crossroads_events',
        'Crossroads Events',
        'your channel description',
        playSound: true,
        enableVibration: true,
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'],
        message['notification']['body'],
        platformChannelSpecifics,
        payload: '');
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {}

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);

//      _auth.db
//          .collection('chats')
//          .document(widget.chatId)
//          .collection('messages')
//          .document(widget.message.id).updateData({
//
//        'state' : 2//le message est lu
//      });

    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BaseScreen()),
    );
  }

  _saveDeviceToken() async {
    _fcm.getToken().then((fcmToken) async {
      FirebaseUser user = await _auth.auth.currentUser();

      _auth.db
          .collection('users')
          .document(user.uid)
          .collection('tokens')
          .document(fcmToken)
          .setData({
        'token': fcmToken,
        'createAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void handlePageChange() {
    _menuPositionController.absolutePosition = _pageController.page;
  }

  void checkUserDragging(ScrollNotification scrollNotification) {
    if (scrollNotification is UserScrollNotification &&
        scrollNotification.direction != ScrollDirection.idle) {
      userPageDragging = true;
    } else if (scrollNotification is ScrollEndNotification) {
      userPageDragging = false;
    }
    if (userPageDragging) {
      _menuPositionController.findNearestTarget(_pageController.page);
    }
  }

//  void onOpenClose(bool b) {
//    if (b) {
//      widget.animationController.forward();
//    } else {
//      widget.animationController.reverse();
//    }
//  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    fetchUnread(user.uid);

    return ScopedModel(
      model: _booModel,
      child: InnerDrawer(
        key: _innerDrawerKey,
        onTapClose: true,
        leftOffset: _offset,
        rightOffset: _offset,
        leftScale: _scale,
        rightScale: _scale,
        borderRadius: _borderRadius,
        swipe: _swipe,
        colorTransition: currentColor,
        leftAnimationType: _animationType,
        rightAnimationType: _animationType,
        innerDrawerCallback: (b) {
          _booModel.change(b);
        },
        leftChild: Material(
            child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  //stops: [0.1, 0.5,0.5, 0.7, 0.9],
                  colors: [
                    ColorTween(
                      begin: Colors.blueAccent,
                      end: Color(0xffF15F79).withRed(100),
                    ).lerp(_dragUpdate),
                    ColorTween(
                      begin: Colors.pink,
                      end: Color(0xffB24592).withGreen(80),
                    ).lerp(_dragUpdate),
                  ],
                ),
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Stack(
                            children: <Widget>[
                              FractionalTranslation(
                                translation: Offset(0.0, 2.1),
                                child: RawMaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/profile');
                                  },
                                  elevation: 10,
                                  shape: StadiumBorder(),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(colors: const [
                                        Color(0xffB24592),
                                        Color(0xffF15F79)
                                      ]),
                                    ),
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      height: 50,
                                      child: Center(
                                        child: Text(
                                          user != null ? user.email : "",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                  alignment: FractionalOffset(0.5, 0.0),
                                  child: CircleAvatar(
                                    radius: 59,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 57,
                                      child: RawMaterialButton(
                                        shape: const CircleBorder(),
                                        splashColor:
                                            Colors.grey.withOpacity(0.4),
                                        onPressed: () => print('coucou'),
                                        padding: const EdgeInsets.all(57.0),
                                      ),
                                      backgroundImage: NetworkImage(
                                        user != null
                                            ? user.photoUrl ??
                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75"
                                            : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75",
                                      ),
                                    ),
                                  )),
//                              Align(
//                                  alignment: FractionalOffset(0.5, 0.0),
//                                  child: CircularProfileAvatar(
//                                    user != null
//                                        ? user.photoUrl
//                                        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75",
//                                    //sets image path, it should be a URL string. default value is empty string, if path is empty it will display only initials
//                                    radius: 57,
//                                    // sets radius, default 50.0
//                                    backgroundColor: Colors.transparent,
//                                    // sets background color, default Colors.white
//                                    borderWidth: 2,
//                                    // sets border, default 0.0
//
//                                    borderColor: Colors.white,
//                                    // sets border color, default Colors.white
//                                    elevation: 0.0,
//                                    // sets elevation (shadow of the profile picture), default value is 0.0
//                                    foregroundColor: Colors.transparent,
//                                    //sets foreground colour, it works if showInitialTextAbovePicture = true , default Colors.transparent
//                                    cacheImage: true,
//                                    // allow widget to cache image against provided url
//                                    onTap: () {
//                                      Navigator.of(context).pushNamed('/profile');
//                                    },
//                                    // sets on tap
//                                    showInitialTextAbovePicture:
//                                        true, // setting it true will show initials text above profile picture, default false
//                                  )),
                            ],
                            //mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 50,
                              ),
                              ListTile(
                                onTap: () => print("Dashboard"),
                                title: Text(
                                  "Mes billets",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.ticketAlt,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Chat",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.comments,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Inviter un ami",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.shareAlt,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Paramètres",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.cogs,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Upload Event",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.upload,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed('/upload_event');
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          ListTile(
                            title: Text(
                              "Se déconnecter",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            leading: Icon(
                              FontAwesomeIcons.signOutAlt,
                              size: 18,
                              color: Colors.white,
                            ),
                            onTap: () async {
                              await _auth.signOut();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/',
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ), //colum
                    ),
                  ),
                );
              }),
            ),
            _dragUpdate < 1
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: (10 - _dragUpdate * 10),
                        sigmaY: (10 - _dragUpdate * 10)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0),
                      ),
                    ),
                  )
                : null,
          ].where((a) => a != null).toList(),
        )),
        scaffold: buildScaffold(context),
        onDragUpdate: (double val, InnerDrawerDirection direction) =>
            setState(() => _dragUpdate = val),
      ),
    );
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
//        appBar:  AppBar(
//          title: Text(
//            "Events",
//            style: TextStyle(color: Colors.white),
//          ),
//          automaticallyImplyLeading: false,
//          leading: IconButton(
//            icon: AnimatedIcon(
//              icon: AnimatedIcons.menu_arrow,
//              progress: _animationController,
//            ),
//            onPressed: () {
//              MyInnerDrawer.innerDrawerKey.currentState.toggle();
//
//            },
//          ),
//          backgroundColor: Colors.pinkAccent,
//          elevation: 10,
//        )  ,
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            checkUserDragging(scrollNotification);
          },
          child: PageView(
            controller: _pageController,
            children: <Widget>[
              EventsScreen(_innerDrawerKey),
              Chat(_innerDrawerKey),
              Billets(_innerDrawerKey),
              Profile(_innerDrawerKey)
            ],
            onPageChanged: (page) {},
          ),
        ),
        bottomNavigationBar: BubbledNavigationBar(
          controller: _menuPositionController,
          initialIndex: 0,
          itemMargin: EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: Colors.white,
          defaultBubbleColor: Colors.blue,
          onTap: (index) {
            _pageController.animateToPage(index,
                curve: Curves.easeInOutQuad,
                duration: Duration(milliseconds: 500));
          },
          items: widget.titles.map((title) {
            var index = widget.titles.indexOf(title);
            var color = widget.colors[index];
            return BubbledNavigationBarItem(
              icon: getIcon(index, color),
              activeIcon: getIcon(index, Colors.white),
              bubbleColor: color,
              title: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }).toList(),
        ));
  }

  fetchUnread(String id) async {
    _auth.db
        .collection('users')
        .document(id)
        .get()
        .then((doc) => User.fromDocSnap(doc))
        .then((user) {
      List<Stream<QuerySnapshot>> queries = [];
      user.chatId.values.forEach((chatId) {
        queries.add(_auth.db
            .collection('chats')
            .document(chatId)
            .collection('messages')
            .where('state', isLessThan: 2)
            .where('idTo', isEqualTo: user.id)
            .snapshots());
      });

      return queries;
    }).then((queries) {
      if (msgNonLu == null) {
        setState(() {
          print("couco2222!!!!$queries");
          msgNonLu = StreamZip(queries).asBroadcastStream();
        });
      }
    });
  }

  Padding getIcon(int index, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Stack(
        children: <Widget>[
          Icon(widget.icons[index], size: 30, color: color),
          index == 1
              ? FractionalTranslation(
                  translation: Offset(0.9, -0.5),
                  child: StreamBuilder(
                      stream: msgNonLu,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox();
                        }

                        int i = 0;

                        snapshot.data.forEach((queries) {
                          queries.documents.forEach((doc) {
                            i++;
                          });
                        });



                        if(i>0){
                          player.play("audio/you-have-new-message.mp3");
                        }

                        return i != 0
                            ? Badge(
                                badgeContent: Text('$i'),
                              )
                            : SizedBox();
                      }),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
