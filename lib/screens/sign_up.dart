import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:crossroads_events/business/validator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/services.dart';
import '../shared/shared.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:image_picker/image_picker.dart';


import 'package:keyboard_actions/keyboard_actions.dart';

class SignUp extends StatefulWidget {
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthService auth = AuthService();

  @override
  void initState() {
    //WidgetsBinding.instance.addPostFrameCallback((_) => getHeight());
    super.initState();

    auth.getUser.then(
      (user) {
        if (user != null && user.isEmailVerified) {
          Navigator.pushReplacementNamed(context, '/events');
        }
      },
    );
  }

  bool isSamePassword(String pass1, String pass2) {
    return pass1 == pass2;
  }

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 150.0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red, Colors.yellow]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20.0,
                    spreadRadius: 1.0,
                  )
                ]),
            padding: EdgeInsets.only(top: statusbarHeight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
        ),
        body: Container(
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
                gradient: LinearGradient(
                  colors: [const Color(0xff662d8c), const Color(0xffed1e79)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                )),
            child: Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          CustomCard(),
                          SizedBox(
                            height: 50,
                          ),
                          ProviderButton(
                            text: 'LOGIN WITH GOOGLE',
                            icon: FontAwesomeIcons.google,
                            color: Colors.black26,
                            loginMethod: auth.googleSignIn,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          ProviderButton(
                            text: 'LOGIN WITH FACEBOOK',
                            icon: FontAwesomeIcons.facebook,
                            color: Colors.black26,
                            loginMethod: auth.faceBookSignIn,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          ProviderButton(
                              text: 'Continue as Guest',
                              loginMethod: auth.anonLogin)
                        ],
                      ),
                    ),
                  );
                }))));
  }
}

class CustomCard extends StatefulWidget {
  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> with WidgetsBindingObserver {
  File _image;
  AuthService auth = AuthService();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String path = image.path;

    print(path.substring(path.lastIndexOf('/') + 1));

    setState(() {
      _image = image;
    });
  }

  AppLifecycleState _appLifecycleState;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmation = TextEditingController();

  bool _obscureTextSignupConfirm = true;

  bool _obscureTextLogin = true;

  double _height = 8.1;
  GlobalKey key = GlobalKey();

  _afterLayout(_) {
    setState(() {
      print(_getSizes());
      _height = _getSizes() / 54.30;
      print(_height);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _afterLayout;
    //WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  _printLatestValue() {
    print("Second text field: ${_password.text}");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      print(state.toString());
      if (state == AppLifecycleState.resumed) {
        print('onresumed!!!!!');
        _afterLayout;
      }
    });
  }

  void setFocus() {
    //FocusScope.of(context).requestFocus(myFocusNodePassword);
  }

  void _onPressed() {
    print('coucou');
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  ValueChanged _onChanged(val) {
    print(val);
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  double _getSizes() {
    //WidgetsBinding.instance.addPostFrameCallback();

    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;

    return sizeRed.height;
    //print("SIZE of Red: $sizeRed");
  }



  void showSnackBar(String val) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  Orientation _orientation;
  bool first = true;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation != _orientation && !first) {
        print('orientation changed!!!');
        _orientation = orientation;
        WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
      } else {
        first = false;
      }

      return Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Container(
          child: Stack(
            children: <Widget>[
              Card(
                key: key,
                elevation: 10,
                color: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Container(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                        colors: const [Color(0xffB24592), Color(0xffF15F79)]),
                  ),
                  child: FormBuilder(
                    onChanged: _onChanged,
                    key: _fbKey,
                    autovalidate: true,
//                  readonly: true,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 70,
                          ),
                          FormBuilderTextField(
                            controller: _name,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            attribute: 'name',
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(25.0)),
                              labelText: 'Nom',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.user,
                                size: 22.0,
                                color: Colors.white,
                              ),
                              errorStyle: TextStyle(color: Colors.white),
                            ),
                            onChanged: _onChanged,
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: 'Champs requis'),
                              (val) {
                                RegExp regex = new RegExp(
                                    r'^[a-zA-Z0-9][a-zA-Z0-9_]{2,15}$');
                                if (regex.allMatches(val).length == 0) {
                                  return 'Entre 2 et 15, ';
                                }
                              }
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderTextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            attribute: 'email',
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(25.0)),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.at,
                                size: 22.0,
                                color: Colors.white,
                              ),
                              errorStyle: TextStyle(color: Colors.white),
                            ),
                            onChanged: _onChanged,
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: 'Champs requis'),
                              FormBuilderValidators.email(
                                  errorText: 'Veuillez saisir un Email valide'),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderTextField(
                            controller: _password,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            attribute: 'mot de passe',
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(25.0)),
                              labelText: 'Mot de passe',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.key,
                                size: 22.0,
                                color: Colors.white,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignupConfirm,
                                child: Icon(
                                  FontAwesomeIcons.eye,
                                  size: 15.0,
                                  color: Colors.white,
                                ),
                              ),
                              errorStyle: TextStyle(color: Colors.white),
                            ),
                            onChanged: _onChanged,
                            validators: [
                              /*Strong passwords with min 8 - max 15 character length, at least one uppercase letter, one lowercase letter, one number, one special character (all, not just defined), space is not allowed.*/

                              (val) {
                                RegExp regex = new RegExp(
                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$');
                                if (regex.allMatches(val).length == 0) {
                                  return 'Entre 8 et 15, 1 majuscule, 1 minuscule, 1 chiffre';
                                }
                              }
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderTextField(
                            controller: _confirmation,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            attribute: 'confirmation',
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(25.0)),
                              labelText: 'Confirmation',
                              labelStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.key,
                                size: 22.0,
                                color: Colors.white,
                              ),
                              errorStyle: TextStyle(color: Colors.white),
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignupConfirm,
                                child: Icon(
                                  FontAwesomeIcons.eye,
                                  size: 15.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onChanged: _onChanged,
                            validators: [
                              (val) {
                                if (_password.text != val)
                                  return 'Pas identique';
                              },
                            ],
                          ),
                          SizedBox(
                            height: 70,
                          ),
                        ]),
                  ),
                ),
              ),
              FractionalTranslation(
                translation: Offset(0.0, -0.5),
                child: Align(
                  alignment: FractionalOffset(0.5, 0.0),
                  child: CircleAvatar(
                      backgroundImage: _image != null
                          ? FileImage(_image)
                          : AssetImage('assets/img/normal_user_icon.png'),
                      radius: 50,
                      child: RawMaterialButton(
                        shape: const CircleBorder(),
                        splashColor: Colors.black45,
                        onPressed: getImage,
                        padding: const EdgeInsets.all(50.0),
                      )),
                ),
              ),
              FractionalTranslation(
                translation: Offset(
                  0.0,
                  _height,
                ),
                child: Align(
                    alignment: FractionalOffset(0.5, 0.0),
                    child: GradientButton(
                        shapeRadius: BorderRadius.circular(25),
                        elevation: 10,
                        increaseHeightBy: 15,
                        increaseWidthBy: 90.0,
                        gradient: Gradients.byDesign,
                        child: Text('Se connecter'),
                        callback: () {
                          _fbKey.currentState.save();
                          if (_fbKey.currentState.validate()) {
                            print(_fbKey.currentState.value);
                            if (_image != null) {
                              auth.register(_email.text, _password.text, _name.text, _image, context);
                              //Navigator.pop(context);
                            } else {
                              showSnackBar('Il manque une photo');
                            }
                          } else {
                            print(_fbKey.currentState.value);
                            showSnackBar("formulaire non valide");
                          }
                        })),
              ),
            ],
          ),
        ),
      );
    });
  }
}
