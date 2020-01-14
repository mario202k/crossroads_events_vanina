import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:crossroads_events/business/validator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/services.dart';
import '../shared/shared.dart';

class SignIn extends StatefulWidget {
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  bool _obscureTextSignupConfirm = true;

  bool _obscureTextLogin = true;

  AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();

    auth.getUser.then(
      (user) {
        if (user != null && user.isEmailVerified) {
          Navigator.pushReplacementNamed(context, '/events');
        }
      },
    );

  }



  void _togglePassword() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  ValueChanged _onChanged(val) {
    print(val);
   // WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();


  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S\'identifier'),
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
                child: FormBuilder(
                  key: _fbKey,
                  autovalidate: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

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

                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                          FormBuilderValidators.email(
                              errorText: 'Veuillez saisir un Email valide'),
                        ],
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
                            onTap: _togglePassword,
                            child: Icon(
                              FontAwesomeIcons.eye,
                              size: 15.0,
                              color: Colors.white,
                            ),
                          ),
                          errorStyle: TextStyle(color: Colors.white),
                        ),
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

                      RawMaterialButton(
                        shape: StadiumBorder(),
                        clipBehavior: Clip.antiAlias,
                        fillColor: Colors.black45,
                        splashColor: Colors.redAccent,
                        onPressed: (){
                          if(_fbKey.currentState.validate()){

                            auth.signIn(_email.text, _password.text).then((user){
                              if(user!= null ){
//                                  && user.isEmailVerified){

                                Navigator.pushReplacementNamed(context, '/baseScreen');

                              }else if(!user.isEmailVerified){
                                showSnackBar("l'email n'est pas vérifié",context);
                              }else{
                                showSnackBar("il faut s'enregistrer",context);
                              }
                            }).catchError((e){
                              print(e);
                              showSnackBar("utilisateur inconnu", context);
                            });

                          }else{
                            showSnackBar("le formulaire est invalide",context);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(FontAwesomeIcons.personBooth, color: Colors.white),
                              Expanded(
                                child: Text(
                                  'Se connecter',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ProviderButton(
                        text: 'AVEC GOOGLE',
                        icon: FontAwesomeIcons.google,
                        color: Colors.black45,
                        loginMethod: auth.googleSignIn,
                      ),
                      ProviderButton(
                        text: 'AVEC FACEBOOK',
                        icon: FontAwesomeIcons.facebook,
                        color: Colors.black45,
                        loginMethod: auth.faceBookSignIn,
                      ),
                      ProviderButton(
                          text: 'Continuer en tant qu\'invité' , loginMethod: auth.anonLogin),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


}
