import 'package:crossroads_events/screens/base_screen.dart';
import 'package:crossroads_events/shared/my_inner_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:scoped_model/scoped_model.dart';

class Billets extends StatefulWidget {

  final GlobalKey<InnerDrawerState> innerDrawerKey;

  const Billets(this.innerDrawerKey) ;



  @override
  _BilletsState createState() => _BilletsState();
}

class _BilletsState extends State<Billets> with TickerProviderStateMixin {

  AnimationController animationController;
  bool toggle =false;

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

    return ScopedModelDescendant<BooModel>(
        builder: (context,child,model) {
          if (model.isOpen) {
            animationController.forward();
          } else {
            animationController.reverse();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Billets",
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



                  if (toggle) {
                    animationController.forward();
                  } else {
                    animationController.reverse();
                  }

                  toggle = !toggle;
                },
              ),
              backgroundColor: Colors.pinkAccent,
              elevation: 10,
            ),
          );

        }
    );




  }
}
