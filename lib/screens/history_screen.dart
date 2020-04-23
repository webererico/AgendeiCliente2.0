import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String uidUser;
  DateTime date;

  getUid () async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      uidUser = user.uid;
    });
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
  void initState() {
    super.initState();
      getUid();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histório'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(uidUser)
            .collection('finishOrders')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: Text('Você não possui agendamentos finalizados'),
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
                                  Text('Nota Serviço: '+snapshot.data.documents[index].data['serviceEvaluation'].toString()),
                                  Text('Nota Funcionário: '+snapshot.data.documents[index].data['employeeEvaluation'].toString()),

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
