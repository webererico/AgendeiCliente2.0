import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/screens/schedule_screen.dart';

class FavoriteTab extends StatefulWidget {
  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  String uidUser;
  QuerySnapshot favorites;
  bool loadingState;

  getUidUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid.toString();
  }

  getFavorites() async {
    QuerySnapshot data = await Firestore.instance
        .collection('users')
        .document(uidUser.toString())
        .collection('favorites')
        .getDocuments()
        .catchError((e) {
      print('erro' + e);
    });
    setState(() {
      favorites = data;
    });
  }

  removeFavorite(String documentUid) async {
    setState(() {
      Firestore.instance
          .collection('users')
          .document(uidUser)
          .collection('favorites')
          .document(documentUid)
          .delete();
    });
  }

  Widget loading() {
    loadingState = true;
    return Padding(
      padding: const EdgeInsets.only(top: 270.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void initState() {
    getUidUser().then((result) {
      setState(() {
        uidUser = result;
      });
      setState(() {
        getFavorites();
      });
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<QuerySnapshot>(
          initialData: favorites,
          future: Firestore.instance
              .collection('users')
              .document(uidUser)
              .collection('favorites')
              .getDocuments(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.documents.length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                        future: Firestore.instance
                            .collection('companies')
                            .document(snapshot.data.documents[index].documentID)
                            .get(),
                        builder: (context, snapshot2) {
                          if (!snapshot2.hasData) {
                            return loadingState == true
                                ? Container()
                                : loading();
                          } else {
                            loadingState = false;
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ScheduleScreen(
                                        snapshot2.data.documentID.toString())));
                              },
                              child: Card(
                                  child: Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 3,
                                    child: Image.network(
                                      snapshot2.data['img'],
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            snapshot2.data['name'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          FutureBuilder(
                                              future: Firestore.instance
                                                  .collection('categories')
                                                  .document(snapshot2
                                                      .data['uidCategory'])
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData)
                                                  return Container();
                                                return Text(
                                                    snapshot.data['name']);
                                              })
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 50.0),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.redAccent,
                                        ),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50.0),
                                    child: IconButton(
                                      icon: Icon(Icons.cancel),
                                      color: Colors.grey,
                                      onPressed: () {
                                        print('clicou');
                                        showDialog<void>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Remover ' +
                                                    snapshot2.data['name'] +
                                                    ' dos favoritos?'),
                                                actions: <Widget>[
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('NÃO')),
                                                  FlatButton(
                                                      onPressed: () {
                                                        removeFavorite(snapshot2
                                                            .data.documentID);
                                                        Navigator.of(context)
                                                            .pop(context);
                                                      },
                                                      child: Text('SIM')),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                ],
                              )),
                            );
                          }
                        });
                  },
                );
              } else if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Text('Você não possui estabelecimentos favoritos'),
                );
              } else {
                return Container();
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
