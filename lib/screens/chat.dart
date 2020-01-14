import 'dart:async';

import 'package:async/async.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossroads_events/main.dart';
import 'package:crossroads_events/screens/chat_room.dart';
import 'package:crossroads_events/services/auth.dart';
import 'package:crossroads_events/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:badges/badges.dart';

import 'base_screen.dart';
import 'const.dart';

class Chat extends StatefulWidget {
  final GlobalKey<InnerDrawerState> innerDrawerKey;

  const Chat(this.innerDrawerKey);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  AnimationController animationController;
  bool toggle = false;
  final AuthService _auth = AuthService();
  List users = [];
  StreamController streamController;
  String myId;
  List<String> lastMessages = [];

  Stream ofUsers, ofLastMsg;

  var _streamUsers;

//  final Bloc userBloc = ;

  @override
  void initState() {
    //Firetore OU logique
    streamController = StreamController.broadcast();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    super.initState();
  }

  setupData(String myId) async {
//    ofUsers = _auth.db
//        .collection('users')
////        .where('id', isGreaterThan: myId)
////        .where('chat', arrayContains: myId)
//        .snapshots();

    ofUsers = StreamZip([
      _auth.db
          .collection('users')
          .where('id', isGreaterThan: myId)
          .where('chat', arrayContains: myId)
          .snapshots(),
      _auth.db
          .collection('users')
          .where('id', isLessThan: myId)
          .where('chat', arrayContains: myId)
          .snapshots()
    ]).asBroadcastStream();

//    ofLastMsg = _auth.db
//        .collection('chats')
//        .document(chatId)
//        .collection('messages')
//        .orderBy('date')
//        .limit(1).snapshots();
//
//    List<User> user1 = await _auth.db
//        .collection('users')
//        .where('id', isGreaterThan: myId)
//        .where('chat', arrayContains: myId)
//        .getDocuments()
//        .then((docs) =>
//            docs.documents.map((doc) => User.fromMap(doc.data)).toList());
//    List<User> user2 = await _auth.db
//        .collection('users')
//        .where('id', isLessThan: myId)
//        .where('chat', arrayContains: myId)
//        .getDocuments()
//        .then((docs) =>
//            docs.documents.map((doc) => User.fromMap(doc.data)).toList());
//
//    setState(() {
//      users = List.from(user1)..addAll(user2);
//    });

//    setState(() {
//      user1.forEach((user) => usersConversations.add(user));
//      user2.forEach((user) => usersConversations.add(user));
//    });

//     users.forEach((user) async {
//
//      String lastConv = await getLastMessage(user.chatId[myId]);
//      setState(() {
//        lastMessages.add(lastConv);
//      });
//
//    });
  }

  Future<String> getLastMessage(String chatId) async {
    String message = await _auth.db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .orderBy('date')
        .limit(1)
        .getDocuments()
        .then((docs) => Message.fromDocSnap(docs.documents.first).message);

    return message;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
    streamController?.close();
    streamController = null;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    myId = user.uid;
    setupData(myId);

//    _queryUser();
    return ScopedModelDescendant<BooModel>(builder: (context, child, model) {
      if (model.isOpen) {
        animationController.forward();
      } else {
        animationController.reverse();
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Chat",
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
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String value) async {
                switch (value) {
                  case 'Value1':
                    final User userFriend = await showSearch(
                        context: this.context,
                        delegate: UserSearch(UserBlocSearchName()));

                    if (userFriend != null) {
                      _auth
                          .creationChatRoom(myId, userFriend.id)
                          .then((chatId) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatRoom(
                                    myId,
                                    userFriend.nom,
                                    userFriend.image,
                                    chatId,
                                    userFriend.id)));
                      });
                    }

                    break;
                  case 'Value2':

//                    final User userFriend = await showSearch(
//                        context: this.context,
//                        delegate: UserSearch(UserBlocSearchEvent()));

//                    if (userFriend != null) {
//                      _auth.creationChatRoom(myId, userFriend.id).then((
//                          chatId) {
//                        Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) =>
//                                    ChatRoom(myId, userFriend.nom,
//                                        userFriend.image, chatId,
//                                        userFriend.id)));
//                      });
//                    }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Icon(FontAwesomeIcons.search),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Value1',
                  child: Text('Par Nom'),
                ),
                const PopupMenuItem<String>(
                  value: 'Value2',
                  child: Text('Y était aussi'),
                ),
              ],
            ),
          ],
          backgroundColor: Colors.pinkAccent,
          elevation: 10,
        ),
        body: StreamBuilder(
            stream: ofUsers,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print("Connecting...");
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                print("Connection Ok");
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur de connection'),
                );
              } else if (!snapshot.hasData) {
                print("pas data");
                return Center(
                  child: Text('Pas de conversation'),
                );
              }

//              List<User> users = List<User> ();
//              users = snapshot.data.documents
//                  .map((doc) => User.fromDocSnap(doc)).toList();

              users.clear();
              snapshot.data.forEach((queries) {
                print(queries.documents);
                queries.documents.forEach((doc) {
                  users.add(User.fromDocSnap(doc));
                });
              });

              return users.isNotEmpty
                  ? ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final User userFriend = users.elementAt(index);
                        Stream msg = _auth.db
                            .collection('chats')
                            .document(userFriend.chatId[myId])
                            .collection('messages')
                            .orderBy('date', descending: true)
                            .limit(1)
                            .snapshots();

                        Stream msgNonLu = _auth.db
                            .collection('chats')
                            .document(userFriend.chatId[myId])
                            .collection('messages')
                            .where('state', isLessThan: 2)
                            .where('idTo', isEqualTo: myId)
                            .snapshots();

                        return StreamBuilder(
                            stream: msg,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text('');
                              }

                              Message message;

                              snapshot.data.documents.forEach((doc) {
                                message = Message.fromDocSnap(doc);
                              });

                              if (message == null) return ListTile();

                              String day = '', month = '';

                              day = message.date.day.toString().length == 1
                                  ? '0${message.date.day.toString()}'
                                  : '${message.date.day.toString()}';

                              month = message.date.month.toString().length == 1
                                  ? '0${message.date.month.toString()}'
                                  : '${message.date.month.toString()}';

                              return ListTile(
                                title: Text(
                                  userFriend.nom,
                                  style: TextStyle(color: Colors.black),
                                ),
                                subtitle: message.type == 0
                                    ? Text(
                                        message.message,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      )
                                    : message.type == 1
                                        ? Row(
                                            children: <Widget>[
                                              Icon(FontAwesomeIcons.photoVideo),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('Photo')
                                            ],
                                          )
                                        : Row(
                                            children: <Widget>[
                                              Icon(FontAwesomeIcons.photoVideo),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('gif')
                                            ],
                                          ),
                                onTap: () {
                                  _auth
                                      .creationChatRoom(myId, userFriend.id)
                                      .then((chatId) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChatRoom(
                                                myId,
                                                userFriend.nom,
                                                userFriend.image,
                                                chatId,
                                                userFriend.id)));
                                  });
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(userFriend.image),
                                  radius: 25,
                                ),
                                trailing: Column(
                                  children: <Widget>[
                                    Text(//si c'est aujourh'hui l'heure sinon date
                                        '${DateTime.now().day != message.date.day ? '$day/$month/${message.date.year}' : '${message.date.hour.toString().length == 1 ? 0 : ''}${message.date.hour}:${message.date.minute.toString().length == 1 ? 0 : ''}${message.date.minute}'}'),
                                    StreamBuilder(
                                        stream: msgNonLu,
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return SizedBox();
                                          }

                                          int i = 0;

                                          snapshot.data.documents
                                              .forEach((doc) {
                                            i++;
                                          });



                                          return i != 0
                                              ? Badge(
                                                  badgeContent: Text('$i'),
                                                  child: Icon(Icons.markunread),
                                                )
                                              : SizedBox();
                                        }),
                                  ],
                                ),
                              );
                            });
                      })
                  : Center(
                      child: Text('Pas de conversation'),
                    );
            }),
      );
    });
  }

// Tout sauf soi-même donc NOT logique
  Future<Stream> _queryUser(String id) async {
    Stream streamOne = _auth.db
        .collection('users')
        .where('id', isGreaterThan: id)
        .snapshots()
        .map((list) => list.documents.map((doc) => User.fromMap(doc.data)))
        .map((data) => data.toList());
    Stream streamTwo = _auth.db
        .collection('users')
        .where('id', isLessThan: id)
        .snapshots()
        .map((list) => list.documents.map((doc) => User.fromMap(doc.data)))
        .map((data) => data.toList());

    return StreamZip([streamOne, streamTwo]).asBroadcastStream();
  }
}

class UserSearch extends SearchDelegate<User> {
  final Bloc<UserSearchEvent, UserSearchState> userBloc;

  UserSearch(this.userBloc);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: BackButtonIcon(),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    userBloc.add(UserSearchEvent(query, user.uid));

    return BlocBuilder(
      bloc: userBloc,
      builder: (BuildContext context, UserSearchState state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError) {
          return Container(
            child: Text('Error'),
          );
        }

//        int j;
//
//        for (int i = 0; i < state.users.length; i++) {
//          if (state.users[i].id == user.uid) {
//            j = i;
//            break;
//          }
//        }
//
//        if (j != null) state.users.removeAt(j);

        return ListView.builder(
          itemBuilder: (context, index) {
            print(index);
            return ListTile(
              title: Text(state.users[index].nom ?? ''),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(state.users[index].image),
                radius: 25,
              ),
              onTap: () {
                close(context, state.users[index]);
              },
            );
          },
          itemCount: state.users.length,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    userBloc.add(UserSearchEvent(query, user.uid));

    return BlocBuilder(
      bloc: userBloc,
      builder: (BuildContext context, UserSearchState state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError) {
          return Container(
            child: Text('Error'),
          );
        }

//        int j;
//
//        for (int i = 0; i < state.users.length; i++) {
//          if (state.users[i].id == user.uid) {
//            j = i;
//            break;
//          }
//        }
//
//        if (j != null) state.users.removeAt(j);

        return ListView.builder(
          itemBuilder: (context, index) {
            print(index);
            return ListTile(
              title: Text(state.users[index].nom ?? ''),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(state.users[index].image),
                radius: 25,
              ),
              onTap: () {
                close(context, state.users[index]);
              },
            );
          },
          itemCount: state.users.length,
        );
      },
    );
  }
}
