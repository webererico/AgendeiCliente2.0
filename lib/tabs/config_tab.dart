import 'package:agendei_cliente/screens/bugReport_screen.dart';
import 'package:agendei_cliente/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfigTab extends StatefulWidget {
  @override
  _ConfigTabState createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  String uidUser;

  getUid() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uidUser = user.uid.toString();
    return uidUser;
  }

  @override
  void initState() {
    super.initState();
    getUid().then((result) {
      setState(() {
        uidUser = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Card(
            margin: new EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10)),
            color: Colors.blueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StreamBuilder<DocumentSnapshot>(
                    stream: Firestore.instance
                        .collection('users')
                        .document(uidUser)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container();
                      } else {
                        if (snapshot.data['img'] != null) {
                          return Image.network(
                            snapshot.data['img'],
                            fit: BoxFit.cover,
                            width: 130,
                            height: 130,
                          );
                        } else {
                          return Container();
                        }
                      }
                    }),
                Text(
                  'Pontuação:',
                  style: TextStyle(color: Colors.white),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('users')
                        .document(uidUser)
                        .collection('finishOrders')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      return Text(snapshot.data.documents.length.toString(),
                          style: TextStyle(color: Colors.white));
                    })
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 25.0 ),
            width: MediaQuery.of(context).size.width,
            child: FlatButton.icon(
              color: Colors.blueAccent,
              icon: Icon(
                Icons.bug_report,
                color: Colors.white,
              ),
              label: Text(
                'Reportar bug no app',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                print('botao reportar bug');
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => BugReportScreen()));
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0 ),
            width: MediaQuery.of(context).size.width,
            child: FlatButton.icon(
              color: Colors.blueAccent,
              icon: Icon(
                Icons.history,
                color: Colors.white,
              ),
              label: Text(
                'Histórico de agendamentos',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                print('botão histórico de agendamento');
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HistoryScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
