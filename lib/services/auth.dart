import 'dart:async';
import 'dart:io';
import 'package:crossroads_events/screens/chat_room.dart';
import 'package:crossroads_events/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum StatusMessage {
  send, //si le serveur a bien reçu
  received, //si la personne est connecter
  read, //si le chatroom est ouvert
  error
}

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  Future<FirebaseUser> get getUser => _auth.currentUser();

  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  FirebaseAuth get auth => _auth;

  Firestore get db => _db;

  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      updateUserDataFromProvider(user, null, null);

      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<FirebaseUser> faceBookSignIn() async {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      FacebookLogin facebookLogin = new FacebookLogin();
      FacebookLoginResult result = await facebookLogin
          .logInWithReadPermissions(['email', 'public_profile']);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          AuthCredential credential = FacebookAuthProvider.getCredential(
              accessToken: result.accessToken.token);
          FirebaseUser user =
              (await FirebaseAuth.instance.signInWithCredential(credential))
                  .user;
          updateUserDataFromProvider(user, null, null);
          return user;
        case FacebookLoginStatus.cancelledByUser:
        case FacebookLoginStatus.error:
        default:
          return null;
      }
    } catch (e) {
      print("Error in facebook sign in: $e");
      return null;
    }
  }

  Future<FirebaseUser> anonLogin() async {
    FirebaseUser user = (await _auth.signInAnonymously()).user;
//    db.collection('users').document(user.uid).updateData({'lastActivity': DateTime.now()});
    return user;
  }

//  void registerNotification() {
//  _firebaseMessaging.requestNotificationPermissions();
//
//  _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
//  print('onMessage: $message');
//  showNotification(message['notification']);
//  return;
//  }, onResume: (Map<String, dynamic> message) {
//  print('onResume: $message');
//  return;
//  }, onLaunch: (Map<String, dynamic> message) {
//  print('onLaunch: $message');
//  return;
//  });
//
//  _firebaseMessaging.getToken().then((token) {
//  print('token: $token');
//  Firestore.instance.collection('users').document(currentUserId).updateData({'pushToken': token});
//  }).catchError((err) {
//  Fluttertoast.showToast(msg: err.message.toString());
//  });
//}
//void configLocalNotification() {
//  var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
//  var initializationSettingsIOS = new IOSInitializationSettings();
//  var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
//  flutterLocalNotificationsPlugin.initialize(initializationSettings);
//}
//
//void showNotification(message) async {
//  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//    Platform.isAndroid ? 'com.dfa.flutterchatdemo': 'com.duytq.flutterchatdemo',
//    'Flutter chat demo',
//    'your channel description',
//    playSound: true,
//    enableVibration: true,
//    importance: Importance.Max,
//    priority: Priority.High,
//  );
//  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
//  var platformChannelSpecifics =
//  new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//  await flutterLocalNotificationsPlugin.show(
//      0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
//      payload: json.encode(message));
//}

  Future<void> updateUserDataFromProvider(
      FirebaseUser user, String password, String photoUrl) {
    DocumentReference documentReference =
        db.collection('users').document(user.uid);

    documentReference.get().then((doc) {
      if (doc.exists) {
        documentReference.updateData({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': photoUrl ?? user.photoUrl,
          'email': user.email,
          'password': password ?? '',
          'lastActivity': DateTime.now(),
          'provider': user.providerId,
          'isLogin': true,
        });
      } else {
        documentReference.setData({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': photoUrl ?? user.photoUrl,
          'email': user.email,
          'password': password,
          'lastActivity': DateTime.now(),
          'provider': user.providerId,
          'isLogin': false,
          'attended': [],
          'willAttend': [],
          'chat': [],
          'chatId': {}
        }, merge: true);
      }
    });
  }

  Future<FirebaseUser> signIn(String email, String password) async {
    FirebaseUser user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    db
        .collection('users')
        .document(user.uid)
        .updateData({'lastActivity': DateTime.now()});

    return user;
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Stream getChatMessages(String chatId) {
    return db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .snapshots();
  }

  Future<String> sendMessage(String chatId, String idSender, String text,
      String friendId, int type) async {
    String messageId = db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document()
        .documentID;

    await db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document(messageId)
        .setData({
      'id': messageId,
      'idFrom': idSender,
      'idTo': friendId,
      'message': text,
      'date': DateTime.now(),
      'type': type,
      'state': 0
    }).catchError((_) {
      Fluttertoast.showToast(msg: 'Problème de connection');
    });

//    await db.collection('chat').document(chatId).updateData({
//
//      'count' : FieldValue.increment(1),
//      'idUsers':[idSender,friendId],
//      'isRead' : false,
//
//      'messages': FieldValue.arrayUnion([
//        {
//          'userFrom': idSender,
//          'message': text,
//          'date': DateTime.now(),
//        }
//      ])
//    }).then((_){
//      //confirmation envoyé
//
//
//      return StatusMessage.send;
//
//    }).catchError((_){
//      return StatusMessage.error;
//    });
  }

  Future<User> getUserFirestore(String id) {
    return db
        .collection('users')
        .document(id)
        .get()
        .then((doc) => User.fromMap(doc.data));
  }

  Future<String> creationChatRoom(String myId, String idFriend) async {
    DocumentReference myUserRef = db.collection('users').document(myId);

    DocumentReference friendUserRef = db.collection('users').document(idFriend);

    List<String> myChat = List<String>();

    //my id
    myChat = await myUserRef
        .get()
        .then((doc) => User.fromMap(doc.data).chat)
        .then((list) => list.cast());

    String idChatRoom = '';

    if (myChat.contains(idFriend)) {
      //fetch idchat

      idChatRoom = await myUserRef
          .get()
          .then((doc) => User.fromDocSnap(doc).chatId[idFriend].toString());

    } else {

      //creation id chat
      //création d'un chatRoom
      DocumentReference chatRoom = db.collection('chats').document();
      idChatRoom = chatRoom.documentID;
      await db.collection('chats').document(idChatRoom).setData({
        'id': idChatRoom,
        'createdAt': DateTime.now(),
      });
      //Partage de l'ID chat room
      await myUserRef.updateData({
        'chat': FieldValue.arrayUnion([idFriend]),
        'chatId': FieldValue.arrayUnion([
          {idFriend: idChatRoom}
        ])
      });
      await friendUserRef.updateData({
        'chat': FieldValue.arrayUnion([myId]),
        'chatId': FieldValue.arrayUnion([
          {myId: idChatRoom}
        ])
      });
    }

//    sonChat = await friendUserRef
//        .get()
//        .then((doc) => User.fromMap(doc.data).chat)
//        .then((list) => list.cast());
//
//
//
//
//
//
//    if (sonChat != null && myChat != null) {
//      for (int j = 0; j < sonChat.length; j++) {
//        if (myChat.contains(sonChat[j])) {
//          idChatRoom = sonChat[j];
//          break;
//        }
//      }
//    }

    return idChatRoom;
  }

  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 4),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }

  void uploadImageChat(
      File image, String chatId, String idSender, String friendId) {
    String path = image.path.substring(image.path.lastIndexOf('/') + 1);

    StorageUploadTask uploadTask = _storageReference
        .child('chat')
        .child(chatId)
        .child("/$path")
        .putFile(image);

    uploadImage(uploadTask)
        .then((url) => sendMessage(chatId, idSender, url, friendId, 1))
        .catchError((err) {
      Fluttertoast.showToast(msg: 'Ce n\'est pas une image');
    });
  }

  void uploadEvent(
      DateTime dateDebut,
      DateTime dateFin,
      String adresse,
      String titre,
      String description,
      File image,
      List<Formule> formules,
      BuildContext context) {
    //création du path pour le flyer
    String path = image.path.substring(image.path.lastIndexOf('/') + 1);

    StorageUploadTask uploadTask = _storageReference
        .child('imageFlyer')
        .child(dateDebut.toString())
        .child("/$path")
        .putFile(image);

    uploadImage(uploadTask).then((url) {
      DocumentReference reference = db.collection("events").document();
      String idEvent = reference.documentID;

      db.collection("events").document(idEvent).setData({
        "id": idEvent,
        "dateDebut": dateDebut,
        "dateFin": dateFin,
        "adresse": adresse,
        "titre": titre,
        "description": description,
        "image": url,
        "participants": [],
      }, merge: true).then((_) {
        formules.forEach((f) {
          DocumentReference reference = db
              .collection("events")
              .document(idEvent)
              .collection("formules")
              .document();
          String idFormule = reference.documentID;

          db
              .collection("events")
              .document(idEvent)
              .collection("formules")
              .document(idFormule)
              .setData({
            "id": idFormule,
            "prix": f.prix,
            "title": f.title,
            "nb": f.nombreDePersonne,
          }, merge: true);
        });
      }).then((_) {
        //création du chat room
        db.collection("chat").document(idEvent).setData(
            {'createdAt': DateTime.now(), 'count': 0, 'messages': []},
            merge: true);
      }).then((_) {
        showSnackBar("Event ajouter", context);
      }).catchError((e) {
        showSnackBar("impossible d'ajouter l'Event", context);
      });
    });
  }

  void register(String email, String password, String nom, File image,
      BuildContext context) {
    //Si l'utilisateur est bien inconnu
    auth.fetchSignInMethodsForEmail(email: email).then((list) {
      if (list.isEmpty) {
        //création du user
        auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((user) {
          //création du path pour la photo profil
          String path = image.path.substring(image.path.lastIndexOf('/') + 1);

          StorageUploadTask uploadTask = _storageReference
              .child('imageProfile')
              .child(user.user.uid)
              .child("/$path")
              .putFile(image);
          //création de l'url pour la photo profil
          uploadImage(uploadTask).then((url) {
            //création du user dans la db
            db.collection('users').document(user.user.uid).setData({
              "id": user.user.uid,
              'nom': nom,
              'imageUrl': url,
              'email': email,
              'password': password,
              'lastActivity': DateTime.now(),
              'provider': user.user.providerId,
              'isLogin': false,
              'attended': [],
              'willAttend': [],
              'chat': [],
              'chatId': {}
            }, merge: true).then((_) {
              print("fait");
              //envoi de l'email de vérification
//              user.user.sendEmailVerification().then((_) {
//                print("fait");
//                showSnackBar('un email de confirmation a été envoyé', context);
//              }).catchError((e) {
//                print(e);
//                showSnackBar('Impossible d\'envoyer l\'e-mail', context);
//              });
            });
          }).catchError((e) {
            print(e);
          });
        }).catchError((e) {
          print(e);
        });
      } else {
        showSnackBar('email existe déjà', context);
      }
    }).catchError((e) {
      print(e);
    });
  }

  Future<String> uploadImage(StorageUploadTask uploadTask) async {
    var url = await (await uploadTask.onComplete).ref.getDownloadURL();

    return url.toString();
  }
}
