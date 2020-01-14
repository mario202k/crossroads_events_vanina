import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossroads_events/screens/pay.dart';
import 'package:crossroads_events/services/models.dart';
import 'package:crossroads_events/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class Details extends StatefulWidget {
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  _DetailsState();

  AuthService _authService = AuthService();
  Stream participants;

  Stream _queryDbParticipant(String id) {
    //Make a query
    Query query =
        _authService.db.collection('users').where("events", arrayContains: id);

    participants =
        query.snapshots().map((list) => list.documents.map((doc) => doc.data));

    return participants;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'stripeCreateCharge',
    );

    final HttpsCallable callableSource = CloudFunctions.instance
        .getHttpsCallable(functionName: 'stripeAttachSource');

    final MonEvent event = ModalRoute.of(context).settings.arguments;

    _queryDbParticipant(event.id);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
//              actions: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(right: 20),
//                  child: InkWell(
//                    onTap: () {
//                      Navigator.of(context).pushNamed('/pay');
//                    },
//                    child: Icon(
//                      FontAwesomeIcons.cartArrowDown,
//                      color: Colors.white,
//                    ),
//                  ),
//                )
//              ],
              expandedHeight: 300,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(event.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )),
                background: Hero(
                    tag: '123',
                    child: Image(
                      image: event.imageProvider,
                      fit: BoxFit.cover,
                    )),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.access_time,
                        color: Colors.cyan,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "à ${event.dateDebut.toDate().hour}:${event.dateDebut.toDate().minute}"),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: (){
                      print('!!!!');
//                      final Event eventt = Event(
//                        title: event.title,
//                        description: event.description,
//                        location: event
//                      )
                    },
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.cyan,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Plannifier"),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.map,
                        color: Colors.cyan,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Allons-y"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                height: 1,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle, color: Colors.black26),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: new Text(
                  "Description",
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text("${event.description}"),
              SizedBox(
                height: 25,
              ),
              Container(
                height: 1,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle, color: Colors.black26),
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Participants",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                height: 200,
                child: StreamBuilder<Object>(
                    stream: participants,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        List users = snapshot.data.toList();


                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            User user = User.fromMap(users[index]);
                            //print("${user.nom}");
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(6),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(user.image),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return Container();
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: RawMaterialButton(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Icon(
                  FontAwesomeIcons.cartArrowDown,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 15,
                ),
                PulseAnimation(
                  child: Text(
                    "RÉSERVER",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          shape: StadiumBorder(),
          fillColor: Colors.purpleAccent,
          onPressed: () {
//            StripeSource.addSource().then((String token) {
//              print("$token!!!"); //your stripe card source token
//              //PaymentService().addCard(token);
//
//              _authService.getUser.then((user) {
//                _attachSource(callableSource,user.uid, token);
//                _chargeCustomer(callable, user.uid, token);
//              });
//            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Pay(event.id)),
            );
            //Navigator.of(context).pushNamed('/pay',arguments: event.id);
          }),
    );
  }




}

class PulseAnimation extends StatefulWidget {
  final Widget child;

  const PulseAnimation({Key key, this.child}) : super(key: key);

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween(begin: .2, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

//class ScreenArguments {
//  final ImageProvider imageProvider;
//
//  ScreenArguments(this.imageProvider);
//
//}

//class HeroHeader implements SliverPersistentHeaderDelegate {
//
//  final double maxExtent;
//  final double minExtent;
//  final FileImage fileImage;
//  final String titre;
//
//  HeroHeader({
//    this.minExtent,
//    this.maxExtent,
//    this.fileImage,
//    this.titre,
//  });
//
//
//  @override
//  Widget build(
//      BuildContext context, double shrinkOffset, bool overlapsContent) {
//    return Stack(
//      fit: StackFit.expand,
//      children: [
//        Image.asset(
//          'assets/ronnie-mayo-361348-unsplash.jpg',
//          fit: BoxFit.cover,
//        ),
//        Container(
//          decoration: BoxDecoration(
//            gradient: LinearGradient(
//              colors: [
//                Colors.transparent,
//                Colors.black54,
//              ],
//              stops: [0.5, 1.0],
//              begin: Alignment.topCenter,
//              end: Alignment.bottomCenter,
//              tileMode: TileMode.repeated,
//            ),
//          ),
//        ),
//        Positioned(
//          left: 0,
//          top: 0,
//          child: SafeArea(
//            child: IconButton(
//              icon: Icon(Icons.arrow_back),
//
//            ),
//          ),
//        ),
//        Positioned(
//          left: 16.0,
//          right: 16.0,
//          bottom: 16.0,
//          child: Text(
//            titre,
//            style: TextStyle(fontSize: 32.0, color: Colors.white),
//          ),
//        ),
//      ],
//    );
//  }
//
//  @override
//  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
//    return true;
//  }
//
//  @override
//  FloatingHeaderSnapConfiguration get snapConfiguration => null;
//}
