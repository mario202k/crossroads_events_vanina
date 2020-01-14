import 'package:flutter/material.dart';

import '../services/services.dart';

class WelcomeScreen extends StatefulWidget {
  createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  AuthService _auth = AuthService();


  @override
  void initState() {

    super.initState();

    // StripeSource.setPublishableKey("pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6");

    _auth.getUser.then(
      (user) {
        if (user != null && user.isEmailVerified) {
          Navigator.pushReplacementNamed(context, '/baseScreen');
        }
      },
    );
  }

  void _navSignin() {
    Navigator.pushNamed(context, '/signin');
  }

  void _navSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crossroads Events'),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color.fromRGBO(21, 153, 163, 1),
            Color.fromRGBO(209, 146, 167, 1),
            Color.fromRGBO(247, 160, 9, 1),
          ],
          tileMode: TileMode.clamp,
        )),
        padding: EdgeInsets.all(30),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Image(
                          fit: BoxFit.contain,
                          image: AssetImage('assets/img/test.png')),
                    ),
                    Text(
                      'Endlessly vibes bring to you',
                      style: Theme.of(context).textTheme.headline,
                      textAlign: TextAlign.center,
                    ),
                    LoginButton(
                      text: 'Se connecter',
                      color: Colors.black45,
                      loginMethod: _navSignin,
                    ),
                    LoginButton(
                      text: 'Créer un compte',
                      color: Colors.black45,
                      loginMethod: _navSignUp,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;

  const LoginButton(
      {Key key, this.text, this.icon, this.color, this.loginMethod})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FlatButton.icon(
        padding: EdgeInsets.all(30),
        icon: Icon(icon, color: Colors.white),
        color: color,
        onPressed: () async {
          var user = await loginMethod();
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/main');
          }
        },
        label: Expanded(
          child: Text('$text', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
