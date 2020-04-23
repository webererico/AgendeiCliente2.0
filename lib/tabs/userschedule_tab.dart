import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/screens/editSchedule_screen.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class UserScheduleTab extends StatefulWidget {
  @override
  _UserScheduleTabState createState() => _UserScheduleTabState();
}

class _UserScheduleTabState extends State<UserScheduleTab> {
  String uidUser;
  DateTime date;
  Timestamp time;
  var serviceRate = 0.0;
  var employeeRate = 0.0;




  @override
  void initState() {
    super.initState();
    getUidUser().then((result) {
      setState(() {
        uidUser = result;
        print(uidUser);
      });
    });
  }

  getUidUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) return null;
    return user.uid.toString();
  }

  Widget companyData(DocumentSnapshot doc, int index) {
    return FutureBuilder(
        future: Firestore.instance
            .collection('companies')
            .document(doc.data['uidCompany'])
            .collection('services')
            .document(doc.data['uidService'])
            .get(),
        builder: (context, snapshot2) {
          if (!snapshot2.hasData) return Container();
          return Row(
            children: <Widget>[
              Text(snapshot2.data['name']),
            ],
          );
        });
  }

  Widget evaluation(DocumentSnapshot order) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
//        _scaffold.currentState.removeCurrentSnackBar();
        return StatefulBuilder(
          builder: (context, setState){
            return  AlertDialog(
              title: Text('Avalie seu atendimento'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Como você avalia o serviço?'),
                    SizedBox(height: 10,),
                    SmoothStarRating(
                      allowHalfRating: false,
                      rating: serviceRate,
                      size: 35,
                      filledIconData: Icons.star,
                      halfFilledIconData: Icons.star_half,
                      defaultIconData: Icons.star_border,
                      color: Colors.yellow,
                      borderColor: Colors.yellow,
                      starCount: 5,
                      spacing: 2.0,
                      onRatingChanged: (value) {
                        setState(() {
                          serviceRate = value;
                        });
                        print('nota serviço: '+serviceRate.toString());
                      },
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Text('E o atendimento pelo funcionário?'),
                    SmoothStarRating(
                      allowHalfRating: false,
                      rating: employeeRate,
                      size: 35,
                      filledIconData: Icons.star,
                      halfFilledIconData: Icons.star_half,
                      defaultIconData: Icons.star_border,
                      color: Colors.yellow,
                      borderColor: Colors.yellow,
                      starCount: 5,
                      spacing: 2.0,
                      onRatingChanged: (value) {
                        setState(() {
                          employeeRate = value;
                        });
                        print('nota funcionario:' +employeeRate.toString());
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                
                FlatButton(
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                    'Avaliar',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    saveEvaluation(order);
                    Navigator.of(context).pop();
//                Navigator.of(context).push(
//                    MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                ),
              ],
            );
          },

        );
      },
    );
  }

  saveEvaluation(DocumentSnapshot order) async{

    Map<String, dynamic> evaluation = {
      'serviceEvaluation': serviceRate,
      'employeeEvaluation': employeeRate,
    };
    print('informando nota ao prestador...');
    Firestore.instance.collection('companies').document(order.data['uidCompany']).collection('services').document(order.data['uidService']).collection('history').document(order.documentID).updateData(evaluation);
    print('informado');
    Firestore.instance.collection('users').document(uidUser).collection('orders').document(order.documentID).delete();
    print('salvando order cliente em finish orders...');
    Firestore.instance.collection('users').document(uidUser).collection('finishOrders').document(order.documentID).setData(order.data);
    Firestore.instance.collection('users').document(uidUser).collection('finishOrders').document(order.documentID).updateData(evaluation);
    print('salvo avaliacao');
    setState(() {
      serviceRate = 0;
      employeeRate = 0 ;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withAlpha(850),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(uidUser)
            .collection('orders')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: Text('Você não possui agendamentos marcados'),
              );
            } else {
              return ListView.builder(
                  padding: EdgeInsets.all(15.0),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    Timestamp value =
                        snapshot.data.documents[index].data['dateTime'];
                    date = DateTime.parse(value.toDate().toString());
                    return Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            child: FutureBuilder<DocumentSnapshot>(
                                future: Firestore.instance
                                    .collection('companies')
                                    .document(snapshot.data.documents[index]
                                        .data['uidCompany'])
                                    .get(),
                                builder: (context, snap) {
                                  if (!snap.hasData)
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  return Image.network(
                                    snap.data['img'],
                                    fit: BoxFit.cover,
                                    width: 130,
                                    height: 130,
                                  );
                                }),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.only(left: 30.0, top: 10),
                              child: Column(
                                children: <Widget>[
                                  FutureBuilder<DocumentSnapshot>(
                                      future: Firestore.instance
                                          .collection('companies')
                                          .document(snapshot
                                              .data
                                              .documents[index]
                                              .data['uidCompany'])
                                          .get(),
                                      builder: (context, snap) {
                                        if (!snap.hasData) return Container();
                                        return Text(
                                          snap.data['name'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        );
                                      }),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'Dia: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(date.day.toString() +
                                          '/' +
                                          date.month.toString() +
                                          '/' +
                                          date.year.toString()),
                                    ],
                                  ),

                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'Horário: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(date.hour.toString() +
                                          ':' +
                                          date.minute.toString()),
                                    ],
                                  ),
                                  companyData(
                                      snapshot.data.documents[index], index),
                                  snapshot.data.documents[index]
                                              .data['statusSchedule'] ==
                                          'finalizado'
                                      ? FlatButton.icon(

                                          color: Colors.orange,
                                          icon: Icon(
                                            Icons.stars,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'Avaliar',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                            evaluation(snapshot.data.documents[index]);
                                          },
                                        )
                                      : FlatButton.icon(
                                          icon: Icon(Icons.edit),
                                          label: Text('alterar'),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditScheduleScreen(
                                                          uidCompany:
                                                              snapshot
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .data[
                                                                  'uidCompany'],
                                                          uidOrder: snapshot
                                                              .data
                                                              .documents[index]
                                                              .documentID,
                                                          uidUser: uidUser,
                                                          order: snapshot.data
                                                              .documents[index],
                                                        )));
                                          },
                                        )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }
          }
        },
      ),
    );
  }
}
