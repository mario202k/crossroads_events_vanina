import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;

  const ProviderButton(
      {Key key, this.text, this.icon, this.color, this.loginMethod})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      fillColor: color,
      splashColor: Colors.redAccent,
      onPressed: () async {
        var user = await loginMethod();

        if (user != null ) {
         // Navigator.of(context).pushReplacementNamed('/event');
          Navigator.pushReplacementNamed(context, '/baseScreen');
        }
      },
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: Colors.white),
            Expanded(
              child: Text(
                '$text',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
