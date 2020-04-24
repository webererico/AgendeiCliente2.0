import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/models/user_model.dart';
import 'package:agendei_cliente/screens/login_screen.dart';
import 'package:agendei_cliente/tiles/drawer_tile.dart';
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
  DocumentSnapshot userData;

  getUidUser() async {
    final FirebaseUser user = await auth.currentUser();
    if (user == null) {
      return false;
    } else if (user != null) {
      userData =
      await Firestore.instance.collection('users').document(user.uid).get();
      return true;
    }
  }

  logOut() async{
    UserModel().signOut();
    signOutGoogle();
    setState(() {
      user = false;
    });
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("saiu google");
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
    Color text (){
      return Colors.white;
    }
    Widget _buildDrawerBack() =>
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 15, 76, 129),
                Color.fromARGB(255, 15, 76, 129),
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
                padding: EdgeInsets.fromLTRB(0.0, 0.0 , 16.0, 8.0),
                height: 170.0,
                child: Stack(
                  children: <Widget>[
                    user == true
                        ? userData.data['img'] != null ? Positioned(
                        left: 5,
                        top: 50,
                        child: CircleAvatar(
                          minRadius: 30,
                          backgroundImage:
                          NetworkImage(userData.data['img']),
                        )): Text('')
                        : Text(''),
                    Positioned(
                      top: user == true ? 30 : 10,
                      right: user == true ? 1.0 : 30,
                      child: user == true ? Image.asset('lib/images/logo_thin.png', scale: 11,): Image.asset('lib/images/logo_thin.png', scale: 9,),
                    ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                user == true ?
                                Text(
                                  'Olá '+userData.data['name'] ,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: text(),
                                  ),
                                ):
//                                Text(
//                                  'Olá' ,
//                                  style: TextStyle(
//                                    fontSize: 20.0,
//                                    fontWeight: FontWeight.bold,
//                                    color: text(),
//                                  ),
//                                ),
                                user == false ? GestureDetector(
                                  child: Text(
                                    'Entre ou cadastre-se >',
                                    style: TextStyle(
                                        color: text(),
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
                            ),

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
                      Icons.person, "Perfil", widget.pageController, 6) ,
                  SizedBox(
                    width: 40.0,
                  ),
                user == true
                          ? FlatButton(
                        child: Icon(Icons.exit_to_app, color: text(),),
                        onPressed: () {
                          print('sair');
                          logOut();
                        },
                      )
                          : Text(''),

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
