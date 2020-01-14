import 'dart:async';
import 'dart:ui';

import 'package:crossroads_events/main.dart';
import 'package:crossroads_events/services/auth.dart';
import 'package:crossroads_events/shared/shared.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';

class MyInnerDrawer extends StatefulWidget {
  final Scaffold scaffoldWidget;

  MyInnerDrawer(this.scaffoldWidget);

  @override
  _MyInnerDrawerState createState() => _MyInnerDrawerState();
}

class BoolModel extends Model {
  bool _boolModel = false;

  bool get boolModel => _boolModel;

  void change(bool b) {
    // First, increment the counter
    _boolModel = b;

    // Then notify all the listeners.
    notifyListeners();
  }
}

class _MyInnerDrawerState extends State<MyInnerDrawer> {
  //Navigation Drawer

//  GlobalKey _keyRed = GlobalKey();
  bool _swipe = true;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.static;
  double _offset = 0.4;
  double _scale = 0.9;
  double _borderRadius = 50;
  Color currentColor = Colors.black54;
  double _dragUpdate = 0;

  final AuthService _auth = AuthService();
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    print('coucou!!!!');

    return InnerDrawer(
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
      innerDrawerCallback: (b) {},
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
                                  padding:
                                      EdgeInsets.only(left: 20.0, right: 20.0),
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
                                          fontSize: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 500,
                              height: 500,
                              child: Container(
                                color: Colors.white,
                                width: 500,
                                height: 500,
//                                child: CircleAvatar(
//                                  radius: 57,
//                                  backgroundColor: Colors.white,
//                                  backgroundImage: NetworkImage(
//                                    user != null
//                                        ? user.photoUrl
//                                        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75",
//                                  ),
//                                ),
                              ),
                            ),
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
                            style: TextStyle(color: Colors.white, fontSize: 14),
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
      scaffold: widget.scaffoldWidget,
      onDragUpdate: (double val, InnerDrawerDirection direction) =>
          setState(() => _dragUpdate = val),
    );
  }
}
