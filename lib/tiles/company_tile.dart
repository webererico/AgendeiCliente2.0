import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/screens/schedule_screen.dart';

class CompanyTile extends StatelessWidget {
  final DocumentSnapshot company;
  final String type;
  final String page;

  CompanyTile(this.type, this.company, this.page);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ScheduleScreen(company.documentID)));
      },
      child: Card(
          elevation: 3.0,
          margin: new EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5, right: 5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: type == 'grid'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.3,
                        child: Image.network(
                          company.data['img'],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              company.data['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder(
                                future: Firestore.instance
                                    .collection('categories')
                                    .document(company.data['uidCategory'])
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return Container();
                                  return Text(
                                    snapshot.data['name'],
                                    overflow: TextOverflow.clip,
                                  );
                                })
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        child: Image.network(
                          company.data['img'],
                          fit: BoxFit.fill,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.only(top: 10, left: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              company.data['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder(
                                future: Firestore.instance
                                    .collection('categories')
                                    .document(company.data['uidCategory'])
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return Container();
                                  return Text(snapshot.data['name']);
                                })
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }
}
