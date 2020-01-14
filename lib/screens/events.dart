//import 'package:js';

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossroads_events/screens/base_screen.dart';
import 'package:crossroads_events/services/models.dart';
import 'package:crossroads_events/shared/my_inner_drawer.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';
//import 'package:circular_profile_avatar/circular_profile_avatar.dart';

import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:crossroads_events/shared/smart_flare_animation.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:crossroads_events/services/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:smart_flare/enums.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:smart_flare/smart_flare.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'details.dart';

const List<String> titles = [
  "Flutter Swiper is awosome",
  "Really nice",
  "Yeap"
];

class EventsScreen extends StatefulWidget {

  final GlobalKey<InnerDrawerState> innerDrawerKey;

  const EventsScreen( this.innerDrawerKey) ;




  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  Stream slides;
  final AuthService _auth = AuthService();
  List<MonEvent> events = List<MonEvent>();
  AnimationController animationController;
  bool toggle =true;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _queryDb(false);
//      SystemChrome.setPreferredOrientations([
//        DeviceOrientation.portraitUp,
//        DeviceOrientation.portraitDown,
//      ]);

    return ScopedModelDescendant<BooModel>(
      builder: (context,child,model){

        if (model.isOpen) {
          animationController.forward();
        } else {
          animationController.reverse();
        }


        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Events",
              style: TextStyle(color: Colors.white),
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: AnimatedIcon(
                icon: AnimatedIcons.menu_arrow,
                progress: animationController,
              ),
              onPressed: () {
                widget.innerDrawerKey.currentState.toggle();


              },
            ),
            backgroundColor: Colors.pinkAccent,
            elevation: 10,
          ),
          body: Container(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                      child: StreamBuilder(
                          stream: slides,
                          initialData: [],
                          builder: (context, AsyncSnapshot snap) {
                            List slideList = snap.data.toList();
                            if (slideList.isNotEmpty) {
                              slideList.forEach((f) {
                                events.add(MonEvent.fromMap(f));
                              });
                            }

                            double width = MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width * 0.1;

                            return Hero(
                              tag: '123',
                              child: slideList.isNotEmpty
                                  ? Swiper(
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  return Image.network(
                                    slideList[index]['image'],
                                    fit: BoxFit.fill,
                                    height: 700,
                                  );
                                },
                                itemCount: slideList.length,
                                pagination: SwiperPagination(),
                                control: SwiperControl(),
                                onTap: (index) {
                                  Navigator.pushNamed(context, '/details',
                                      arguments: events[index]);
                                },
                                itemWidth: width,
                                itemHeight: (width * 6) / 4.25,
                                layout: SwiperLayout.TINDER,
                                loop: true,
                                outer: true,
                                autoplay: true,
                                autoplayDisableOnInteraction: false,
                              )
                                  : Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }) //streambuilder
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Stream _queryDb(bool upcoming) {
    if (upcoming) {
      //Make a query
      Query query = _auth.db
          .collection('events');
//          .where('dateDebut', isGreaterThanOrEqualTo: DateTime.now());


      slides = query
          .snapshots()
          .map((list) => list.documents.map((doc) => doc.data));
    } else {
      //Make a query
      Query query = _auth.db
          .collection('events');
//          .where('dateDebut', isLessThan: DateTime.now());

      slides = query
          .snapshots()
          .map((list) => list.documents.map((doc) => doc.data));
    }

    return slides;
  }
}
