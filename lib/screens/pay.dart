import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crossroads_events/services/auth.dart';
import 'package:crossroads_events/services/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:stripe_payment/stripe_payment.dart';

class Pay extends StatefulWidget {
  final String id;

  Pay(this.id);

  @override
  _PayState createState() => _PayState();
}

class _PayState extends State<Pay> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _error;
  Token _paymentToken;

  //final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  List<Formule> _formules = List<Formule>();
  AuthService _authService = AuthService();
  Stream slides;
  List slideList;

  String _nom = '', _prenom = '';

  double _total = 0;

  Formule _formuleOngoing;

  @override
  void dispose() {
    _formules.clear();
    super.dispose();
  }

  @override
  void initState() {
    _queryDb(widget.id);

    super.initState();

    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6",
        merchantId: "Test",
        androidPayMode: 'test'));

    //_listCardItem = List<CardItem>();
  }

  void setError(dynamic error) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
    });
  }

  Stream _queryDb(String id) {
    Query query = _authService.db
        .collection('events')
        .document(id)
        .collection('formules');

    slides =
        query.snapshots().map((list) => list.documents.map((doc) => doc.data));

    return slides;
  }

  @override
  Widget build(BuildContext context) {
//    setState(() {
//      //nombreDePersonne = List<int>.filled(events.formules.length, 0);
//    });

    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text(
        "Paiement",
      )),
      body: Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height-80),
            child: StreamBuilder(
              stream: slides,
//            initialData: [],
              builder: (context, AsyncSnapshot snap) {
                if (snap.hasData && _formules.isEmpty) {
                  snap.data.toList().forEach((f) {
                    _formules.add(Formule.fromMap(f));
                  });
                }

                return snap.hasData
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedList(
                          key: _listKey,
                          initialItemCount: _formules.length,
                          itemBuilder: (BuildContext context, int index,
                              Animation<double> animation) {
                            return SizeTransition(
                              axis: Axis.vertical,
                              sizeFactor: animation,
                              child:
                                  _buildItem(_formules[index], index, animation),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: const CircularProgressIndicator(),
                      );
              },
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Material(
                  color: Colors.orange,
                  elevation: 14.0,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                  shadowColor: Color(0x802196F3),
                  child: _buildTotalContent(),
                )
              ],
            ),
//        child: Container(child: _formules(events.formules)),

//        child: Column(
//          children: <Widget>[
//            Text(events.title),
//            _formules(events.formules),
//            Text('Montant total: $_total €'),
//            RawMaterialButton(
//              onPressed: (){},
//              child: Icon(FontAwesomeIcons.creditCard,color: Colors.purpleAccent,size: 30.0,),
//              shape: StadiumBorder(),
//              elevation: 5.0,
//              fillColor: Color(0xffFAF4F2),
//              padding: const EdgeInsets.all(10.0),
//            ),
//
//          ],
//        )
          ),
        ],
      ),
    );
  }

  _buildTotalContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,

        child: Column(
          children: <Widget>[
            Text('Total : $_total €',textAlign: TextAlign.center,),
            RawMaterialButton(
              onPressed: (){
                print('pay!!!');
                StripePayment.paymentRequestWithNativePay(
                  androidPayOptions: AndroidPayPaymentRequest(
                    total_price: _total.toString(),
                    currency_code: "EUR",
                  ),
                  applePayOptions: ApplePayPaymentOptions(
                    countryCode: 'FR',
                    currencyCode: 'EUR',
                    items: [
                      ApplePayItem(
                        label: 'Test',
                        amount: '13',
                      )
                    ],
                  ),
                ).then((token) {
                  setState(() {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${token.tokenId}')));
                    _paymentToken = token;
                  });
                }).catchError(setError);
              },
              child: Icon(FontAwesomeIcons.creditCard,
                color: Colors.purpleAccent,
                size: 30.0,),
              shape: CircleBorder(),
              elevation: 5.0,
              fillColor: Color(0xffFAF4F2),
              padding: const EdgeInsets.all(10.0),
            ),
          ],
        ),
      ),
    );
  }

  void _onChangedPrenom(val) {
    _prenom = val;
  }

  void _onChangedNom(val) {
    _nom = val;
  }

  Widget _buildRemovedItem(int index) {
    return cardForm();
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(Formule formule, int index, Animation<double> animation) {
    return formule.prix != null
        ? CardItem((bool plus, int prix, int nombreDePersonne, int index) {
            if (plus) {
              index = index + nombreDePersonne;

              _formules.insert(index, Formule());
              _listKey.currentState
                  .insertItem(index, duration: Duration(milliseconds: 500));

              setState(() {
                _total = _total + prix;
              });
            } else {
              index = index + nombreDePersonne;
              _formules.removeAt(index);
              _listKey.currentState.removeItem(
                index,
                (BuildContext context, Animation<double> animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                        parent: animation, curve: Interval(0.5, 1.0)),
                    child: SizeTransition(
                      sizeFactor: CurvedAnimation(
                          parent: animation, curve: Interval(0.0, 1.0)),
                      axisAlignment: 0.0,
                      child: _buildRemovedItem(index),
                    ),
                  );
                },
                duration: Duration(milliseconds: 600),
              );
              setState(() {
                _total = _total - prix;
              });
            }
          }, formule, index, _formules)
        : cardForm();
  }

  Widget cardForm() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        child: Card(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          color: Colors.amber,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Text('Participant'),
                  FormBuilder(
//                    key: _fbKey,
                    autovalidate: false,
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          attribute: 'nom',
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(25.0)),
                            labelText: 'Nom',
                            labelStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                            errorStyle: TextStyle(color: Colors.white),
                          ),
                          onChanged: _onChangedNom,
                          validators: [
                            FormBuilderValidators.required(
                                errorText: 'Champs requis'),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        FormBuilderTextField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          attribute: 'prenom',
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(25.0)),
                            labelText: 'Prénom',
                            labelStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                            errorStyle: TextStyle(color: Colors.white),
                          ),
                          onChanged: _onChangedPrenom,
                          validators: [
                            FormBuilderValidators.required(
                                errorText: 'Champs requis'),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _chargeCustomer(
      HttpsCallable callable, String uid, String token) async {
    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{'source': token, 'amount': 7000, 'uid': uid},
      );
      print('!1!${result.data}');
//      setState(() {
//        _response = result.data['repeat_message'];
//        _responseCount = result.data['repeat_count'];
//      });
    } on CloudFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print('caught generic exception');
      print(e);
    }
  }

  Future _attachSource(
      HttpsCallable callableSource, String uid, String token) async {
    try {
      final HttpsCallableResult result = await callableSource.call(
        <String, dynamic>{'uid': uid, 'source': token},
      );
      print('!2!${result.data}');
//      setState(() {
//        _response = result.data['repeat_message'];
//        _responseCount = result.data['repeat_count'];
//      });
    } on CloudFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print('caught generic exception');
      print(e);
    }
  }
}

class CardItem extends StatefulWidget {
  final Formule formule;
  final Function onTap;
  final int index;
  List<Formule> formules;

  CardItem(this.onTap, this.formule, this.index, this.formules);

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem>
    with AutomaticKeepAliveClientMixin {
  int _nombreDePersonne;
  int nb;

  @override
  void initState() {
    nb = 0;
    setState(() {
      _nombreDePersonne = 0;
    });

    countnb();
    super.initState();
  }

  void countnb() {
    for (int i = widget.index + 1;
        i < widget.formules.length && widget.formules[i].prix == null;
        i++) {
      nb++;
    }

    setState(() {
      _nombreDePersonne = nb;
    });
    nb = 0;
  }

  Widget listTileForm() {
    return ListTile(
      title: Center(
          child: Text(
        '${widget.formule.title} : ${widget.formule.prix} €',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      )),
      leading: RawMaterialButton(
        onPressed: () {
          if (_nombreDePersonne > 0) {
            widget.onTap(
                false, widget.formule.prix, _nombreDePersonne, widget.index);
            _nombreDePersonne--;

            countnb();
          }
        },
        child: Icon(
          FontAwesomeIcons.minus,
          color: Colors.purpleAccent,
          size: 30.0,
        ),
        shape: CircleBorder(),
        elevation: 5.0,
        fillColor: Color(0xffFAF4F2),
        padding: const EdgeInsets.all(10.0),
      ),
      subtitle: Center(child: Text(_nombreDePersonne.toString())),
      trailing: RawMaterialButton(
        onPressed: () {
          if (_nombreDePersonne >= 0) {
            widget.onTap(
                true, widget.formule.prix, _nombreDePersonne + 1, widget.index);
            _nombreDePersonne++;

            countnb();
          }
        },
        child: Icon(
          FontAwesomeIcons.plus,
          color: Colors.purpleAccent,
          size: 30.0,
        ),
        shape: CircleBorder(),
        elevation: 5.0,
        fillColor: Color(0xffFAF4F2),
        padding: const EdgeInsets.all(10.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    countnb();

    return _nombreDePersonne > 0
        ? Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              height: 128.0,
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                          '${widget.formule.title} : ${widget.formule.prix} €'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              if (_nombreDePersonne > 0) {
                                widget.onTap(false, widget.formule.prix,
                                    _nombreDePersonne, widget.index);
                                _nombreDePersonne--;

                                countnb();
                              }
                            },
                            child: Icon(
                              FontAwesomeIcons.minus,
                              color: Colors.purpleAccent,
                              size: 30.0,
                            ),
                            shape: CircleBorder(),
                            elevation: 5.0,
                            fillColor: Color(0xffFAF4F2),
                            padding: const EdgeInsets.all(10.0),
                          ),
                          Text(_nombreDePersonne.toString()),
                          RawMaterialButton(
                            onPressed: () {
                              if (_nombreDePersonne >= 0) {
                                widget.onTap(true, widget.formule.prix,
                                    _nombreDePersonne + 1, widget.index);
                                _nombreDePersonne++;

                                countnb();
                              }
                            },
                            child: Icon(
                              FontAwesomeIcons.plus,
                              color: Colors.purpleAccent,
                              size: 30.0,
                            ),
                            shape: CircleBorder(),
                            elevation: 5.0,
                            fillColor: Color(0xffFAF4F2),
                            padding: const EdgeInsets.all(10.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : listTileForm();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
