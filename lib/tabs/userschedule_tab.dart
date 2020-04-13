import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/screens/editSchedule_screen.dart';

class UserScheduleTab extends StatefulWidget {
  @override
  _UserScheduleTabState createState() => _UserScheduleTabState();
}

class _UserScheduleTabState extends State<UserScheduleTab> {
  String uidUser;
  DateTime date;
  Timestamp time;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withAlpha(850),
      body: FutureBuilder<QuerySnapshot>(
        future: Firestore.instance
            .collection('users')
            .document(uidUser)
            .collection('orders')
            .where('statusSchedule', isEqualTo: 'agendado')
            .getDocuments(),
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
                    Timestamp value =snapshot.data.documents[index].data['dateTime'];
                    date = DateTime.parse(value.toDate().toString());
                    return Card(
                      child: Row(
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
                              padding: EdgeInsets.only(left: 30.0,top: 10),
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
                                  SizedBox(height: 5,),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'Dia: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(date.day.toString()+'/'+date.month.toString()+'/'+date.year.toString()),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        'Horário: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(date.hour.toString()+':'+date.minute.toString()),
                                    ],
                                  ),

                                  companyData(
                                      snapshot.data.documents[index], index),
                                  FlatButton.icon(
                                    icon: Icon(Icons.edit),
                                    label: Text('alterar'),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditScheduleScreen(
                                                    uidCompany: snapshot
                                                        .data
                                                        .documents[index]
                                                        .data['uidCompany'],
                                                    uidOrder: snapshot
                                                        .data
                                                        .documents[index]
                                                        .documentID,
                                                    uidUser: uidUser,
                                                    order: snapshot
                                                        .data.documents[index],
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
