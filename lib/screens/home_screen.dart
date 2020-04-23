import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/screens/profile_screen.dart';
import 'package:agendei_cliente/screens/schedule_screen.dart';
import 'package:agendei_cliente/tabs/config_tab.dart';
import 'package:agendei_cliente/tabs/favorites_tab.dart';
import 'package:agendei_cliente/tabs/home_tab.dart';
import 'package:agendei_cliente/tabs/payment_tab.dart';
import 'package:agendei_cliente/tabs/userschedule_tab.dart';
import 'package:agendei_cliente/tabs/services_tab.dart';
import 'package:agendei_cliente/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  List<DocumentSnapshot> companyList;
  List<Map<dynamic, dynamic>> companies = new List();

  void getData() async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection('companies').getDocuments();
    companyList = querySnapshot.documents;
    companies = companyList.map((DocumentSnapshot doc) {
      return doc.data;
    }).toList();
    print(companies);
  }

  void deleteUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.delete();

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Estabelecimentos'),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      print('buscar');
                      showSearch(context: context, delegate: CompanySearch());
                    }),
              ],
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
            body: HomeTab(),
            drawer: CustomDrawer(_pageController),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text('Serviços'),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: ServicesTab(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text('Agendamentos'),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: UserScheduleTab(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text('Favoritos'),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: FavoriteTab(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text('Métodos de Pagamento'),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: PaymentTab(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text('Configurações'),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: ConfigTab(),
        ),
        Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                'Tem certeza que deseja apagar sua conta?'),
                            content: Text(
                                'Todos seus dados de agendamento serão apagados'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancelar'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Center(
                                    child: CircularProgressIndicator(),
                                  );
                                  deleteUser();
                                },
                                child: Text(
                                  'Apagar definitivamente',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ))
            ],
            title: Text('Perfil'),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: ProfileScreen(),
        ),
      ],
    );
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
    final QuerySnapshot querySnapshot =
        await Firestore.instance.collection('companies').getDocuments();
    final List<DocumentSnapshot> documents = querySnapshot.documents;
    documents.forEach((data) {
      if (!companies.contains(data['name'])) {
        companies.add(data['name']);
      }
    });
    print(companies.length);
  }

  void discoverUid(BuildContext context, String name) async {
    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection('companies')
        .where('name', isEqualTo: name)
        .getDocuments();
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
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          print(suggestionList[index]);
          discoverUid(context, suggestionList[index]);
        },
        title: RichText(
          text: TextSpan(
              text: suggestionList[index].substring(0, query.length),
              style: TextStyle(
                  color: Colors.blueAccent, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: suggestionList[index].substring(query.length),
                    style: TextStyle(color: Colors.grey))
              ]),
        ),
      ),
      itemCount: suggestionList.length,
    );
  }
}
