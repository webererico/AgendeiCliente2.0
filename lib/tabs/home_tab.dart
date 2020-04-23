import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/tiles/company_tile.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> categories = [];
    for(var x = 0 ; x < 10 ; x++){
      categories.add(Container(
          height: 60.0,
          width: 60.0,
          margin: EdgeInsets.all(
              6.0
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              boxShadow:[
                new BoxShadow(
                    color: Color.fromARGB(100, 0, 0, 0),
                    blurRadius: 5.0,
                    offset: Offset(5.0, 5.0)
                )
              ],
              border: Border.all(
                  width: 2.0,
                  style:BorderStyle.solid ,
                  color: Color.fromARGB(255, 0 , 0, 0)
              ),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage("https://cdn.dribbble.com/users/1368/screenshots/1785863/icons_2x.png")
              )
          )
      )
      );
    }
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
          future: Firestore.instance.collection('companies').getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else
              return TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    GridView.builder(
                        padding: EdgeInsets.all(4.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return CompanyTile(
                              "grid", snapshot.data.documents[index], 'home');
                        }),
                        ListView.builder(
                        padding: EdgeInsets.all(4.0),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return CompanyTile(
                              "list", snapshot.data.documents[index], 'home');
                        })
                  ]);
          }),
    );
  }
}
