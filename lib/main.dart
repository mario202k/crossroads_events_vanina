import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossroads_events/screens/base_screen.dart';
import 'package:crossroads_events/screens/chat_room.dart';
import 'package:crossroads_events/shared/my_inner_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'services/services.dart';
import 'screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MessageHandler extends StatefulWidget {
  final String id;

  MessageHandler(this.id);

  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final AuthService _authService = AuthService();

  final Firestore _db = Firestore.instance;
//  final FirebaseMessaging _fcm = FirebaseMessaging();
//  StreamSubscription iosSubscription;

  @override
  void initState() {
    super.initState();
//    if (Platform.isIOS) {
//      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
//        // save the token  OR subscribe to a topic here
//        _saveDeviceToken();
//      });
//
//      _fcm.requestNotificationPermissions(IosNotificationSettings());
//    } else {
//      _saveDeviceToken();
//    }
//
//    _fcm.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print("onMessage: $message");
//        showDialog(
//          context: context,
//          builder: (context) => AlertDialog(
//            content: ListTile(
//              title: Text(message['notification']['title']),
//              subtitle: Text(message['notification']['body']),
//            ),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('Ok'),
//                onPressed: () => Navigator.of(context).pop(),
//              ),
//            ],
//          ),
//        );
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//        print("onLaunch: $message");
//        // TODO optional
//      },
//      onResume: (Map<String, dynamic> message) async {
//        print("onResume: $message");
//        // TODO optional
//      },
//    );
  }

//  _saveDeviceToken() async {
//    _fcm.getToken().then((fcmToken) async {
//      print('token: $fcmToken');
//
//      FirebaseUser user = await _authService.auth.currentUser();
//
//      Firestore.instance
//          .collection('users')
//          .document(user.uid)
//          .collection('tokens')
//          .document(fcmToken)
//          .setData({
//        'token': fcmToken,
//        'createAt': FieldValue.serverTimestamp(),
//        'platform': Platform.operatingSystem
//      });
//    }).catchError((err) {
//      Fluttertoast.showToast(msg: err.message.toString());
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

//class UserBlocSearchEvent extends Bloc<UserSearchEvent, UserSearchState> {
//  final AuthService _auth = AuthService();
//  List<User> saufMoi = List<User>();
//  User mee;
//
//  @override
//  UserSearchState get initialState => UserSearchState.initial();
//
//  @override
//  void onTransition(Transition<UserSearchEvent, UserSearchState> transition) {
//    print(transition.toString());
//  }
//
//  @override
//  Stream<UserSearchState> mapEventToState(UserSearchEvent event) async* {
//    yield UserSearchState.loading();
//
//    try {
//      List<User> users = await _getSearchResults(event.query);
//      yield UserSearchState.success(users);
//    } catch (_) {
//      yield UserSearchState.error();
//    }
//  }
//
//  Future<List<User>> _getSearchResults(String query) async {
//    List<User> result = List<User>();
//
//    if (saufMoi.isEmpty) {
////      FirebaseUser me = await _auth.auth.currentUser();
////
////      User mee = await _auth.getUserFirestore(me.uid);
////
////      List<User> user1 = await _auth.db
////          .collection('users')
////          .where('nom', isGreaterThan: mee.nom)
////          .getDocuments()
////          .then((docs) =>
////              docs.documents.map((doc) => User.fromMap(doc.data)).toList());
////      List<User> user2 = await _auth.db
////          .collection('users')
////          .where('nom', isLessThan: mee.nom)
////          .getDocuments()
////          .then((docs) =>
////              docs.documents.map((doc) => User.fromMap(doc.data)).toList());
////
////      saufMoi = List.from(user1)..addAll(user2); //Tout le monde sauf moi
////      result = saufMoi;
//
//      List<User> user = await _auth.db
//          .collection('users')
//          .getDocuments()
//          .then((docs) =>
//          docs.documents.map((doc) => User.fromMap(doc.data)).toList());
//
//      saufMoi = user;
//      result = saufMoi;
//
//    } else {
//      for (int i = 0; i < saufMoi.length; i++) {
//        for (int j = 0; j < saufMoi[i].willAttend.length; j++) {
//          if (mee.willAttend.contains(saufMoi[i].willAttend[j])) {
//            result.add(saufMoi[i]);
//            break;
//          }
//        }
//      }
//    }
//
//    return result;
//  }
//}

class UserBlocSearchName extends Bloc<UserSearchEvent, UserSearchState> {
  final AuthService _auth = AuthService();
  List<User> users = List<User>();

  @override
  UserSearchState get initialState => UserSearchState.initial();

  @override
  void onTransition(Transition<UserSearchEvent, UserSearchState> transition) {
    print(transition.toString());
  }

  @override
  Stream<UserSearchState> mapEventToState(UserSearchEvent event) async* {
    yield UserSearchState.loading();

    try {
      List<User> users = await _getSearchResults(event.query,event.myId);
      yield UserSearchState.success(users);
    } catch (err) {
      yield UserSearchState.error();
    }
  }

  Future<List<User>> _getSearchResults(String query,String myId) async {
    List<User> result = List<User>();

    if (users.isEmpty) {
//      FirebaseUser me = await _auth.auth.currentUser();
//
//      User mee = await _auth.getUserFirestore(me.uid);
//      users = await _auth.db.collection('users').getDocuments().then(
//          (docs) =>
//              docs.documents.map((doc) => User.fromMap(doc.data)).toList());

    print("$myId!!!!!!!!!!!!");
      List<User> user1 = await _auth.db
          .collection('users')
          .where('id', isGreaterThan: myId)
          .getDocuments()
          .then((docs) =>
              docs.documents.map((doc) => User.fromMap(doc.data)).toList());
      List<User> user2 = await _auth.db
          .collection('users')
          .where('id', isLessThan: myId)
          .getDocuments()
          .then((docs) =>
              docs.documents.map((doc) => User.fromMap(doc.data)).toList());

      users = List.from(user1)..addAll(user2); //Tout le monde sauf moi



    result = List.from(users);

    } else {
      users.forEach((user) {
        if (user.nom.contains(query)) {
          result.add(user);
        }
      });
    }

    return result;
  }
}

class UserSearchEvent {
  final String query;
  final String myId;

  const UserSearchEvent(this.query,this.myId);

  @override
  String toString() => 'UserSearchEvent { query: $query }';
}

class UserSearchState {
  final bool isLoading;
  final List<User> users;
  final bool hasError;

  const UserSearchState({this.isLoading, this.users, this.hasError});

  factory UserSearchState.initial() {
    return UserSearchState(
      users: [],
      isLoading: false,
      hasError: false,
    );
  }

  factory UserSearchState.loading() {
    return UserSearchState(
      users: [],
      isLoading: true,
      hasError: false,
    );
  }

  factory UserSearchState.success(List<User> users) {
    return UserSearchState(
      users: users,
      isLoading: false,
      hasError: false,
    );
  }

  factory UserSearchState.error() {
    return UserSearchState(
      users: [],
      isLoading: false,
      hasError: true,
    );
  }

  @override
  String toString() =>
      'UserSearchState {users: ${users.toString()}, isLoading: $isLoading, hasError: $hasError }';
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //StreamProvider<Report>.value(stream: Global.reportRef.documentStream),
        StreamProvider<FirebaseUser>.value(value: AuthService().user)
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          '/': (context) => WelcomeScreen(),
          '/signin': (context) => SignIn(),
          '/signup': (context) => SignUp(),
          '/upload_event': (context) => UploadEvent(),
          '/details': (context) => Details(),
          '/baseScreen': (context) => BaseScreen(),
        },
        theme: ThemeData(
          primaryColor: Color.fromRGBO(209, 16, 167, 1),
          appBarTheme: AppBarTheme(
            color: Color.fromRGBO(247, 160, 9, 1),
          ),
          fontFamily: 'Nunito',
          bottomAppBarTheme: BottomAppBarTheme(
            color: Colors.black87,
          ),
          textTheme: TextTheme(
            body1: TextStyle(fontSize: 18),
            body2: TextStyle(fontSize: 16),
            button: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
            headline:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            subhead: TextStyle(color: Colors.grey),
          ),
          buttonTheme: ButtonThemeData(),
        ),
      ),
    );
  }
}
