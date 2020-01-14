import 'package:crossroads_events/services/auth.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:smart_flare/smart_flare.dart';


class SmartFlareAnimation extends StatefulWidget {
  @override
  _SmartFlareAnimationState createState() => _SmartFlareAnimationState();
}

class _SmartFlareAnimationState extends State<SmartFlareAnimation>  {

  final AuthService _auth = AuthService();

  static const double AnimationWidth = 600;
  static const double AnimationHeight = 1280;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double ratio = AnimationWidth/AnimationHeight;

    double width = height* ratio - 37.7;

    var relativePanArea = [
      RelativePanArea(
        area: Rect.fromLTRB(0, 0.33, 1, 0.65),
        debugArea: true,),
      ActiveArea(
          area: Rect.fromLTWH(
              0,
              height * 0.836 - 73,
              width,
              height * 0.073),
          debugArea: true,
          guardComingFrom: ['open'],
          onAreaTapped: () {

            Navigator.pushNamed(context, '/upload_event');
          }),
      ActiveArea(
          area: Rect.fromLTWH(
              0,
              height * 0.91 - 73,
              width,
              height * 0.073),
          debugArea: true,
          onAreaTapped: () async {
            await _auth.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
                  (route) => false,
            );
          }),
    ];

    return PanFlareActor(
      width: width,
      height: height,
      filename: 'assets/animation/drawer.flr',
      openAnimation: 'open',
      closeAnimation: 'close',
      direction: ActorAdvancingDirection.RightToLeft,
      threshold: width/2,
      reverseOnRelease: true,
      completeOnThresholdReached: true,
      activeAreas: relativePanArea,
    );
  }



}
