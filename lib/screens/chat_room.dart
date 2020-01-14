import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossroads_events/screens/const.dart';
import 'package:crossroads_events/screens/full_photo.dart';
import 'package:crossroads_events/services/auth.dart';
import 'package:crossroads_events/services/models.dart';
import 'package:crossroads_events/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoom extends StatefulWidget {
  final String myId;
  final String nomFriend;
  final String imageFriend;
  final String chatId;
  final String friendId;

  ChatRoom(
      this.myId, this.nomFriend, this.imageFriend, this.chatId, this.friendId);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with TickerProviderStateMixin {
  AuthService _authService = AuthService();
  List<Message> _messages = List<Message>();
  Timestamp _lastTimestamp;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  TextEditingController _textEditingController = TextEditingController();

  StreamSubscription<QuerySnapshot> stream;
  StreamSubscription<QuerySnapshot> stream2;

  static AudioCache player = AudioCache();

  @override
  void initState() {
    stream = _authService.db
        .collection('chats')
        .document(widget.chatId)
        .collection('messages')
        .where('state', isEqualTo: 1)
        .where('idFrom', isEqualTo: widget.friendId)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) {
        print(doc['id']);

        _authService.db
            .collection('chats')
            .document(widget.chatId)
            .collection('messages')
            .document(doc['id'])
            .updateData({'state': 2});
      });
    });

    stream2 = _authService.db
        .collection('chats')
        .document(widget.chatId)
        .collection('messages')
        .where('state', isEqualTo: 0)
        .where('idFrom', isEqualTo: widget.friendId)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) {
        print(doc['id']);

        _authService.db
            .collection('chats')
            .document(widget.chatId)
            .collection('messages')
            .document(doc['id'])
            .updateData({'state': 2});
      });
    });

    super.initState();
  }

  Future<bool> getListChat(String userId) async {
    bool b = await _authService.db
        .collection('user')
        .document(userId)
        .snapshots()
        .map(((doc) => User.fromMap(doc.data)))
        .first
        .then((user) {
      return true;
    });

    return b;
  }

  @override
  void dispose() {
    if (stream != null) stream.cancel();
    if (stream2 != null) stream2.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    final FirebaseUser user = Provider.of<FirebaseUser>(context);
//
//    final User userDestinataire = ModalRoute.of(context).settings.arguments;

    //Verification existing chat room ou création chat room

    return Scaffold(
        appBar: AppBar(
            elevation: 0.4,
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            title: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.imageFriend),
                    backgroundColor: Colors.grey[200],
                    maxRadius: 22,
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.nomFriend,
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        'En ligne',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            )),
        body: Column(children: [
          Flexible(
            child: StreamBuilder(
              stream: _authService.db
                  .collection('chats')
                  .document(widget.chatId)
                  .collection('messages')
                  .orderBy('date', descending: false)
                  .snapshots(),
//                  .map((list) => list.documents.map((doc) => doc.data)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                    child: Text('Pas de message'),
                  );
                }
//                _messages.clear();
//                List slideList = snapshot.data.toList();
//                if (slideList.isNotEmpty) {
//                  slideList.forEach((f) {
//                    _messages.add(Message.fromMap(f));
//                  });
//                }

//                if(snapshot.data != null && snapshot.data.documents != null)
//                  print('aezrtjygtkhjkml${snapshot.data.documents[0]['message']}');

//                List listMessage = snapshot.data.toList();
//                if (listMessage.isNotEmpty) {
//                  listMessage.forEach((data) {
//                    messages.add(Message.fromMap(data));
//                  });
//                }

//                Chat chat = Message.fromMap(snap.data);

//                List<Message> messages =
//                    snap.data.documents.map((doc) => Message.fromMap(doc));
//                messages.sort((a, b) => b.date.compareTo(a.date));

//                _messages.clear();

//                _authService.db.collection('chats').document(widget.chatId).collection('messages').where('date', isGreaterThan:  )

                if (snapshot.data.documents.length > 0) {
                  if (_lastTimestamp == null) {
                    snapshot.data.documents.forEach((data) {
                      Message messageNew = Message.fromDocSnap(data);

                      _messages.insert(0, messageNew);

//                      if(widget.myId != messageNew.idFrom){
//                        _authService.db
//                            .collection('chats')
//                            .document(widget.chatId)
//                            .collection('messages')
//                            .document(messageNew.id).updateData({
//
//                          'state': 2 //le message est lu
//                        });
//                      }
                    });

                    _lastTimestamp = snapshot.data.documents.last['date'];
                  } else {
                    _authService.db
                        .collection('chats')
                        .document(widget.chatId)
                        .collection('messages')
                        .where('date', isGreaterThan: _lastTimestamp)
                        .getDocuments()
                        .then((docs) {
                      docs.documents.forEach((doc) {
                        Message messageNew = Message.fromDocSnap(doc);

                        _messages.insert(0, messageNew);
                        _listKey.currentState.insertItem(0,
                            duration: Duration(milliseconds: 500));

//                        if(widget.myId != messageNew.idFrom){
//                          _authService.db
//                              .collection('chats')
//                              .document(widget.chatId)
//                              .collection('messages')
//                              .document(messageNew.id).updateData({
//
//                            'state': 2 //le message est lu
//                          });
//                        }
                      });
                    });
                    player.play("audio/i-demand-attention.mp3");
                    _lastTimestamp = snapshot.data.documents.last['date'];
                  }
                }

                return _messages.isNotEmpty
                    ? AnimatedList(
                        initialItemCount: _messages.length,
                        key: _listKey,
                        padding: EdgeInsets.all(8.0),
                        reverse: true,
                        itemBuilder: (BuildContext context, int index,
                            Animation<double> animation) {
                          return SizeTransition(
                              axis: Axis.vertical,
                              sizeFactor: animation,
                              child: !isAnotherDay(index, _messages)
                                  ? ChatMessageListItem(
                                      _messages[index],
                                      widget.myId == _messages[index].idFrom,
                                      widget.chatId)
                                  : Column(
                                      children: <Widget>[
                                        Text(isToday(_messages[index].date)
                                            ? 'Aujourd\'hui'
                                            : isYesterday(_messages[index].date)
                                                ? 'Hier'
                                                : ' ${day(_messages[index].date.weekday)} ${_messages[index].date.day} ${month(_messages[index].date.month)}'),
                                        ChatMessageListItem(
                                            _messages[index],
                                            widget.myId ==
                                                _messages[index].idFrom,
                                            widget.chatId)
                                      ],
                                    ));
                        },
                      )
                    : Center(
                        child: Text('Pas de message'),
                      );
              },
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 2,
          ),
          Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer()),
        ]));
  }

  String day(int week) {
    switch (week) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
    }
  }

  String month(int month) {
    switch (month) {
      case DateTime.january:
        return 'Janvier';
      case DateTime.february:
        return 'Février';
      case DateTime.march:
        return 'Mars';
      case DateTime.april:
        return 'Avril';
      case DateTime.may:
        return 'Mai';
      case DateTime.june:
        return 'Juin';
      case DateTime.july:
        return 'Juillet';
      case DateTime.august:
        return 'Août';
      case DateTime.september:
        return 'Septembre';
      case DateTime.october:
        return 'Octobre';
      case DateTime.november:
        return 'Novembre';
      case DateTime.december:
        return 'Décembre';
    }
  }

  bool isAnotherDay(int index, List<Message> messages) {
    bool b = false;

    if (index == messages.length - 1) {
      return true;
    }

    if (index > 0 && index < messages.length - 1) {
      if (messages[index].date.day > messages[index + 1].date.day) {
        b = true;
      }
    }

    return b;
  }

  bool isToday(DateTime date) {
    bool b = false;

    if (date.day == DateTime.now().day) {
      b = true;
    }
    print(date.day);

    return b;
  }

  bool isYesterday(DateTime date) {
    bool b = false;

    if (date.day + 1 == DateTime.now().day) {
      b = true;
    }
    print(date.day);

    return b;
  }

  Future _getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    String path = image.path;
    print(path.substring(path.lastIndexOf('/') + 1));
    _authService.uploadImageChat(
        image, widget.chatId, widget.myId, widget.friendId);
  }

  Future _getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String path = image.path;
    print(path.substring(path.lastIndexOf('/') + 1));
    _authService.uploadImageChat(
        image, widget.chatId, widget.myId, widget.friendId);
  }

  YYDialog YYAlertDialogWithBackgroundColor() {
    return YYDialog().build(context)
      ..width = 240
      ..borderRadius = 4.0
      ..backgroundColor = Colors.white
      ..text(
        padding: EdgeInsets.all(18.0),
        text: "Upload flyer",
        color: Colors.black,
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      )
      ..text(
        padding: EdgeInsets.only(left: 18.0, right: 18.0),
        text: "Choissisez la source",
        color: Colors.grey[500],
      )
      ..doubleButton(
        padding: EdgeInsets.only(top: 24.0),
        gravity: Gravity.center,
        text1: "CAMERA",
        color1: Colors.deepPurpleAccent,
        fontSize1: 14.0,
        text2: "GALLERY",
        color2: Colors.deepPurpleAccent,
        fontSize2: 14.0,
        onTap1: _getImageCamera,
        onTap2: _getImageGallery,
      )
      ..show();
  }

  Widget _buildTextComposer() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(children: [
          Container(
            child: IconButton(
              icon: Icon(Icons.photo),
              onPressed: () {
                YYAlertDialogWithBackgroundColor();
              },
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.gif),
              onPressed: () {
                pickGif(context);
              },
            ),
          ),
          Flexible(
            child: TextField(
              controller: _textEditingController,
//              onChanged: _handleMessageChanged,
              decoration:
                  InputDecoration.collapsed(hintText: 'Saisir un message'),
              maxLines: null,
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_textEditingController.text))),
        ]));
  }

//  void _addMessage(
//      {String name,
//        String text,
//        String imageUrl,
//        String textOverlay,
//        String senderImageUrl}) {
//    var animationController = AnimationController(
//      duration: Duration(milliseconds: 700),
//      vsync: this,
//    );
//    var sender = ChatUser(name: name, imageUrl: senderImageUrl);
//    var message = ChatMessage(
//        sender: sender,
//        text: text,
//        imageUrl: imageUrl,
//        textOverlay: textOverlay,
//        animationController: animationController);
//    setState(() {
//      _messages.insert(0, message);
//    });
//    if (imageUrl != null) {
//      NetworkImage image = NetworkImage(imageUrl);
//      image
//          .resolve(createLocalImageConfiguration(context))
//          .addListener((_, __) {
//        animationController?.forward();
//      });
//    } else {
//      animationController?.forward();
//    }
//  }

  void pickGif(BuildContext context) async {
    final gif = await GiphyPicker.pickGif(
        context: context, apiKey: 'nZXOSODAIyJlsmNBMXzz55JvV5f8kd0D');

    if (gif != null) {
      _authService.sendMessage(widget.chatId, widget.myId,
          gif.images.original.url, widget.friendId, 3);
    }
  }

  void _sendMessage(String text) {
    if (text.trim() != '') {
      _textEditingController.clear();
      _authService
          .sendMessage(widget.chatId, widget.myId, text, widget.friendId, 0)
          .catchError((err) {
        _textEditingController.text = text;
      });
    } else {
      print('Text vide ou null');
    }
  }
}

class ChatMessageListItem extends StatefulWidget {
  final Message message;
  final bool isMe;
  final String chatId;

  ChatMessageListItem(this.message, this.isMe, this.chatId);

  @override
  _ChatMessageListItemState createState() => _ChatMessageListItemState();
}

class _ChatMessageListItemState extends State<ChatMessageListItem> {
  AuthService _authService = AuthService();
  bool isReceive = false;
  bool isRead = false;
  String id;

  Widget build(BuildContext context) {
    id = widget.message.id; //Car l'animated list reconstruit que le build

    return Container(
      margin: EdgeInsets.only(top: 4, bottom: 4),
      child: widget.message.type == 0
          ? Row(
              mainAxisAlignment:
                  widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                widget.isMe
                    ? StreamBuilder(
                        //pour écouté si le message est lu
                        stream: _authService.db
                            .collection('chats')
                            .document(widget.chatId)
                            .collection('messages')
                            .where('id', isEqualTo: id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            snapshot.data.documents.forEach((data) {
                              Message message = Message.fromDocSnap(data);
                              int state = message.state;

                              isReceive = false;
                              isRead = false;

                              switch (state) {
                                case 1:
                                  isReceive = true;
                                  break;
                                case 2:
                                  isRead = true;
                                  isReceive = true;
                              }
                            });
                          }

                          return Icon(
                            IconData(isReceive ? 0xf382 : 0xf3d0,
                                fontFamily: "CupertinoIcons"),
                            size: 19,
                            color: isRead ? Colors.green : Colors.grey,
                          );
                        })
                    : SizedBox(),
                widget.isMe
                    ? Text(
                        //horaire
                        '${widget.message.date.hour.toString().length == 1 ? 0 : ''}${widget.message.date.hour}:${widget.message.date.minute.toString().length == 1 ? 0 : ''}${widget.message.date.minute}',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      )
                    : SizedBox(),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: widget.isMe
                        ? LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            stops: [
                                0.1,
                                1
                              ],
                            colors: [
                                Colors.red,
                                Color(0xFFFDA085),
                              ])
                        : LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            stops: [
                                0.1,
                                1
                              ],
                            colors: [
                                Colors.blue,
                                Color(0xFFEBF5FC),
                              ]),
                    borderRadius: widget.isMe
                        ? BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                            bottomRight: Radius.circular(0),
                            bottomLeft: Radius.circular(15),
                          )
                        : BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                            bottomLeft: Radius.circular(0),
                          ),
                  ),
                  child: Text(
                    widget.message.message,
                    textAlign: widget.isMe ? TextAlign.end : TextAlign.start,
                    style: TextStyle(
                      color: widget.isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                !widget.isMe
                    ? Text(
                        //horaire
                        '${widget.message.date.hour.toString().length == 1 ? 0 : ''}${widget.message.date.hour}:${widget.message.date.minute.toString().length == 1 ? 0 : ''}${widget.message.date.minute}',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      )
                    : SizedBox(),
              ],
            )
          : widget.message.type == 1
              ? Container(
//            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FullPhoto(url: widget.message.message)));
                    },
                    padding: EdgeInsets.all(0),
                    child: Material(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: greyColor2,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Material(
                          child: Image.asset(
                            'assets/img/img_not_available.jpeg',
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: widget.message.message,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : Container(
                  child: Image.network(
                    widget.message.message,
                  ),
                ),
    );
  }
}
