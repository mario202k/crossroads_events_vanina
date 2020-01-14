import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crossroads_events/services/db.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'auth.dart';

class MonEvent {
  final String id;
  final String title;
  final String description;
  final ImageProvider imageProvider;
  final Timestamp dateDebut;
  final Timestamp dateFin;
  List<Formule> formules = List<Formule>();

  MonEvent(
      {this.id,
      this.title,
      this.description,
      this.imageProvider,
      this.dateDebut,
      this.dateFin,
      this.formules});

  factory MonEvent.fromMap(Map data) {
    return MonEvent(
        id: data['id'] ?? '',
        title: data['titre'] ?? '',
        description: data['description'] ?? '',
        imageProvider: NetworkImage(
          data['image'],
        ),
        dateDebut: data['dateDebut'],
        dateFin: data['dateFin']);
  }
}

class Participant {
  final String nom;
  final String prenom;

  Participant(this.nom, this.prenom);
}

class Formule {
  final String id;
  String title;
  int prix;
  int nombreDePersonne;

  Formule({this.id, this.title, this.prix, this.nombreDePersonne});

  void titleSet(String string) {
    title = string;
  }

  factory Formule.fromMap(Map data) {
    return Formule(
        id: data['id'] ?? '',
        title: data['title'] ?? '',
        prix: data['prix'] ?? '',
        nombreDePersonne: 0);
  }
}

class User {
  final String id;
  final String email;
  final String image;
  final bool isLogin;
  final Timestamp lastActivity;
  final String nom;
  final String password;
  final String provider;
  final List willAttend;
  final List attended;
  final List chat;
  final Map chatId;

  User(
      {this.id,
      this.email,
      this.image,
      this.isLogin,
      this.lastActivity,
      this.nom,
      this.password,
      this.provider,
      this.willAttend,
      this.attended,
      this.chat,
      this.chatId});

  factory User.fromMap(Map data) {

    return User(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      isLogin: data['isLogin'] ?? false,
      image: data['imageUrl'] ??
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75",
      lastActivity: data['lastActivity'],
      nom: data['nom'] ?? '',
      password: data['password'] ?? '',
      provider: data['provider'] ?? '',
      willAttend: data['willAttend'] as List ?? [],
      attended: data['attended'] as List ?? [],
      chat: data['chat'] as List ?? [],
      chatId: data['chatId'].toString().length == 2 ? {}: Map.fromIterable((data['chatId'] as List),//2 = est vide
              key: (v) => v.toString().substring(
                  v.toString().indexOf('{') + 1, v.toString().indexOf(':')),
              value: (v) => v.toString().substring(
                  v.toString().indexOf(':') + 1, v.toString().indexOf('}')).trim()),
    );
  }

  factory User.fromDocSnap(DocumentSnapshot data) {

    return User(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      isLogin: data['isLogin'] ?? false,
      image: data['imageUrl'] ??
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75",
      lastActivity: data['lastActivity'],
      nom: data['nom'] ?? '',
      password: data['password'] ?? '',
      provider: data['provider'] ?? '',
      willAttend: data['willAttend'] as List ?? [],
      attended: data['attended'] as List ?? [],
      chat: data['chat'] as List ?? [],
      chatId: data['chatId'].toString().length == 2 ? {}: Map.fromIterable((data['chatId'] as List),
          key: (v) => v.toString().substring(
              v.toString().indexOf('{') + 1, v.toString().indexOf(':')),
          value: (v) => v.toString().substring(
              v.toString().indexOf(':') + 1, v.toString().indexOf('}')).trim()),
    );
  }

  @override
  String toString() => 'User { name: $nom }';
}

//class Chat {
//  final Timestamp date;
//  final String chatId;
//  final int count;
//  final List<Message> messages;
//  final bool isRead;
//
//
//  Chat({this.date, this.chatId, this.count, this.messages, this.isRead});
//
//  factory Chat.fromMap(Map data) {
//    print(data);
//
//    return Chat(
//        date: data['createdAt'] ?? '',
//        chatId: data['id'] ?? '',
//        count: data['count'] ?? '',
//        messages: (data['messages'] as List)
//                .map((msg) => Message.fromMap(msg))
//                .toList() ??
//            [],
//      isRead: data['isRead']
//        );
//  }
//}

class Message {
  final String id;
  final String idFrom;
  final String idTo;
  final String message;
  final DateTime date;
  final int type;
  final int state;

  Message(
      {this.id,
      this.idFrom,
      this.idTo,
      this.message,
      this.date,
      this.type,
      this.state});

  factory Message.fromDocSnap(DocumentSnapshot data) {
    Timestamp time = data['date'] ?? '';

    return Message(
        id: data['id'] ?? '',
        idFrom: data['idFrom'] ?? '',
        idTo: data['idTo'] ?? '',
        message: data['message'] ?? '',
        date: time.toDate() ?? '',
        type: data['type'] ?? '',
        state: data['state'] ?? '');
  }

  factory Message.fromMap(Map data) {
    Timestamp time = data['date'] ?? '';

    return Message(
        id: data['id'] ?? '',
        idFrom: data['idFrom'] ?? '',
        idTo: data['idTo'] ?? '',
        message: data['message'] ?? '',
        date: time.toDate() ?? '',
        type: data['type'] ?? '',
        state: data['state'] ?? '');
  }
}
