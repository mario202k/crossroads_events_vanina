import 'package:crossroads_events/screens/welcome.dart';
import 'package:crossroads_events/services/auth.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/services.dart';
import '../shared/shared.dart';
import 'package:provider/provider.dart';
//import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class Profile extends StatefulWidget {
  final GlobalKey<InnerDrawerState> innerDrawerKey;

  const Profile(this.innerDrawerKey);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService auth = AuthService();


  @override
  Widget build(BuildContext context) {
    //Report report = Provider.of<Report>(context);
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    String userName = user.displayName;

    var upperCased = userName.split(" ").map((s){

      return s[0].toUpperCase()+s.substring(1);
    });

    userName = upperCased.join(" ");


    if (user != null) {
      return Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipPath(
                clipper: OvalBottomBorderClipper(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 230,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: const [Color(0xffB24592), Color(0xffF15F79)]),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(userName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontFamily: 'WorkSansSemiBold'),
                  ),
                ),
              ),
              FractionalTranslation(
                translation: Offset(0.0, 1.4),
                child: Align(
                  alignment: FractionalOffset(0.5, 0.0),
                  child: Stack(children: <Widget>[
                    CircleAvatar(
                      radius: 59,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 57,
                        child: RawMaterialButton(
                          shape: const CircleBorder() ,
                          splashColor: Colors.grey.withOpacity(0.4),
                          onPressed: ()=>print('coucou'),
                          padding: const EdgeInsets.all(57.0),
                        ),
                        backgroundImage: NetworkImage(
                          user != null
                              ? user.photoUrl
                              : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75",
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 80,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 8,
                          ),
                        )),
                  ]),
                ),
              ),
              FractionalTranslation(
                translation: Offset(0.0, 3.28),
                child: Align(
                  alignment: FractionalOffset(0.15, 0.0),
                  child: FloatingActionButton(
                    onPressed: toChat,
                    child: Icon(FontAwesomeIcons.userPlus),
                  ),
                ),
              ),
              FractionalTranslation(
                translation: Offset(0.0, 3.28),
                child: Align(
                  alignment: FractionalOffset(0.85, 0.0),
                  child: FloatingActionButton(
                    onPressed: toChat,
                    child: Icon(FontAwesomeIcons.comments),
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                user.email ?? '',
                style: TextStyle(color: Colors.black),
              ),
              FlatButton(
                  child: Text('logout'),
                  color: Colors.red,
                  onPressed: () async {
                    await auth.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  }),
            ],
          )
        ],
      );
    } else {
      return LoadingScreen();
    }
  }

  void toChat() {
    print('chat');
  }
}
//
//class ClippingClass extends CustomClipper<Path> {
//  @override
//  Path getClip(Size size) {
//    var path = Path();
//
//    path.lineTo(0.0, size.height );
//    path.quadraticBezierTo(
//        size.width / 4, size.height-60, size.width / 2, size.height);
//
//    path.quadraticBezierTo(size.width - (size.width / 10), size.height,
//        size.width, size.height -90);
//
//    path.lineTo(size.width, 0.0);
//
//    return path;
//  }
//
//  @override
//  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
//}
