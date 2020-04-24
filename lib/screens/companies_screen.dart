import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/screens/schedule_screen.dart';
import 'package:agendei_cliente/tiles/company_tile.dart';

class CompaniesScreen extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final String categoryName;
  final List<DocumentSnapshot> companyList = new List();
  final List<Map<dynamic, dynamic>> companies = new List();

  CompaniesScreen(this.snapshot, this.categoryName);

  @override
  _CompaniesScreenState createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: Firestore.instance
            .collection('companies')
            .where('uidCategory', isEqualTo: widget.snapshot.documentID)
            .getDocuments(),
        builder: (context, snapshot) {
          print(snapshot);
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
              ),
              body: Container(

                child: Center(child: CircularProgressIndicator()),
              ) ,

            );
          } else {
            return DefaultTabController(
              length: 2,
              child: Scaffold(

                appBar: AppBar(
                  title: Text(widget.categoryName == null  ? ' ': widget.categoryName),
//                  title: Text('teste'),
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          print('buscar');
                          showSearch(context: context, delegate: CompanySearch());
                        }),
                  ],
                  centerTitle: true,
                  bottom: TabBar(
                    indicatorColor: Colors.white,
                    tabs: <Widget>[
                      Tab(
                        icon: Icon(Icons.grid_on),
                      ),
                      Tab(
                        icon: Icon(Icons.list),
                      )
                    ],
                  ),
                ),
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
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
                          if(index == null){
                            return Center(child: CircularProgressIndicator(),);
                          }else{
                          return CompanyTile("grid",
                              snapshot.data.documents[index], 'category');

                        }} ),
                    ListView.builder(
                        padding: EdgeInsets.all(4.0),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return CompanyTile("list",
                              snapshot.data.documents[index], 'category');
                        })
                  ],
                ),
              ),
            );
          }
        });
  }
}
class CompanySearch extends SearchDelegate<String> {

  final recentSearch = [
    'Lavagem LavaCar',
    'Consultório Palermo',
    'Barbearia Padova',
    'Barbearia Stylo',
  ];

  final companies = [];
  String uidCompany;

  void getData() async {
    final QuerySnapshot querySnapshot = await Firestore.instance.collection(
        'companies').getDocuments();
    final List<DocumentSnapshot> documents = querySnapshot.documents;
    documents.forEach((data) {
      if (!companies.contains(data['name'])) {
        companies.add(data['name']);
      }
    });
    print(companies.length);
  }

  void discoverUid(BuildContext context, String name) async {
    final QuerySnapshot querySnapshot = await Firestore.instance.collection(
        'companies').where('name', isEqualTo: name).getDocuments();
    String uidCompany = querySnapshot.documents[0].documentID;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ScheduleScreen(uidCompany)));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getData();
    final suggestionList = query.isEmpty
        ? recentSearch
        : companies.where((p) => p.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) =>
          ListTile(
            onTap: () {
              print(suggestionList[index]);
              discoverUid(context, suggestionList[index]);
            },
            title: RichText(text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: suggestionList[index].substring(query.length),
                      style: TextStyle(color: Colors.grey)
                  )
                ]
            ),),
          ),
      itemCount: suggestionList.length,
    );
  }
}
