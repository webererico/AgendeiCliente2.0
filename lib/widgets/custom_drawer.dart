import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/models/user_model.dart';
import 'package:agendei_cliente/screens/login_screen.dart';
import 'package:agendei_cliente/tiles/drawer_tile.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomDrawer extends StatefulWidget {
  final PageController pageController;

  CustomDrawer(this.pageController);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool user;
  DocumentSnapshot documentSnapshot;

  getUidUser() async {
    final FirebaseUser user = await auth.currentUser();
    if (user == null) {
      return false;
    } else if (user != null) {
      documentSnapshot =
      await Firestore.instance.collection('users').document(user.uid).get();
      return true;
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  @override
  void initState() {
    getUidUser().then((result) {
      setState(() {
        user = result;
      });
      print('Usuário logado: ' + user.toString());

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildDrawerBack() =>
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(200, 87, 39, 239),
                Color.fromARGB(120, 66, 90, 242),
//                Colors.blueAccent,
//                Color.fromARGB(255, 203, 236, 241),
//                Color.fromARGB(255, 203, 236, 241),
//                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

    return Drawer(
      child: Stack(
        children: <Widget>[
          _buildDrawerBack(),
          ListView(
            padding: EdgeInsets.only(left: 32.0, top: 16.0),
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.fromLTRB(0.0, 30.0, 16.0, 8.0),
                height: 170.0,
                child: Stack(
                  children: <Widget>[
                    user == true
                        ? documentSnapshot.data['img'] != null ? Positioned(
                        left: 10,
                        child: CircleAvatar(
                          minRadius: 30,
                          backgroundImage:
                          NetworkImage(documentSnapshot.data['img']),
                        )): Text('')
                        : Text(''),
                    Positioned(
                      top: 1.0,
                      right: user == true ? 12.0 : 60,
                      child: Text(
                        'Agendei',
                        style: TextStyle(
                            fontSize: 38.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child: ScopedModelDescendant<UserModel>(
                          builder: (context, child, model) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Olá, ${!model.isLoggedIn() ? "" : (model
                                      .userData['name'])}',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                !model.isLoggedIn()
                                    ? GestureDetector(
                                  child: Text(
                                    'Entre ou cadastre-se >',
                                    style: TextStyle(
                                        color: Theme
                                            .of(context)
                                            .primaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LoginScreen()),
                                    );
                                  },
                                )
                                    : Text('')
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
              Divider(),
              DrawerTile(
                  Icons.home, "Estabelecimentos", widget.pageController, 0),
              DrawerTile(Icons.list, "Serviços", widget.pageController, 1),
              user == true
                  ? DrawerTile(Icons.calendar_today, "Agendamentos",
                  widget.pageController, 2)
                  : Text(''),
              user == true
                  ? DrawerTile(
                  Icons.favorite, "Favoritos", widget.pageController, 3)
                  : Text(''),
              user == true
                  ? DrawerTile(Icons.payment, "Métodos de pagamento",
                  widget.pageController, 4)
                  : Text(''),
              user == true
                  ? DrawerTile(
                  Icons.settings, "Configurações", widget.pageController, 5)
                  : Text(''),
              user == true
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  DrawerTile(
                      Icons.person, "Perfil", widget.pageController, 6),
                  SizedBox(
                    width: 40.0,
                  ),
                  ScopedModelDescendant<UserModel>(
                    builder: (context, child, model) {
                      return model.isLoggedIn()
                          ? FlatButton(
                        child: Icon(Icons.exit_to_app),
                        onPressed: () {
                          print('sair');
                          model.signOut();
                          setState(() {
                            user = false;
                          });
                        },
                      )
                          : Text('');
                    },
                  ),
                ],
              )
                  : Text(''),
            ],
          ),
        ],
      ),
    );
  }
}
