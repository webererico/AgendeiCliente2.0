import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agendei_cliente/screens/home_screen.dart';
import 'package:agendei_cliente/screens/signupEmail_screen.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';



class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterPage();
  }
}

class _RegisterPage extends State<RegisterScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String name;
  String email;
  String imageUrl;


  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    print('entrou');

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    Map<String, dynamic> userData ={
    'name': user.displayName,
    'email' : user.email,
    'img' : user.photoUrl
    };
    name = user.displayName;
    email = user.email;
    imageUrl = user.photoUrl;
    Firestore.instance.collection('users').document(user.uid).setData(userData);
    print('salvou');
    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async{
    await googleSignIn.signOut();

    print("User Sign Out");
  }



  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color _cor1 = Color.fromARGB(255, 25, 25, 112);
    final Color _cor2 = Color.fromARGB(255, 79, 79, 216);
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_cor1, _cor2],
                  ),
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(90))),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              size: 50,
                              color: Colors.white,
                            ),
                            Text(
                              'Agendei',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        )),
                    Spacer(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Escolha um método',
              style: TextStyle(
                  fontSize: 30.0, fontWeight: FontWeight.bold, color: _cor1),
            ),
            Divider(),
            SizedBox(
              height: 100.0,
            ),
            Center(
              child: SignInButtonBuilder(
                text: 'Entrar com o e-mail',
                icon: Icons.email,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context)=>SignupScreen())
                  );
                },
                backgroundColor: Colors.blueGrey[700],
                width: 220.0,

//                  height: 20.0,
              ),
            ),

            SignInButton(
              Buttons.Google,
              text: "Entrar com Google",
              onPressed: () {
                Center(child: CircularProgressIndicator(),);
                signInWithGoogle().whenComplete(() {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomeScreen();
                      },
                    ),
                  );
                });

              },
            ),
            SignInButton(
              Buttons.Apple,
              text: "Entrar com Apple",
              onPressed: () {
//                _showButtonPressDialog(context, 'Apple');
              },
            ),
            SignInButton(
              Buttons.Facebook,
              text: "Entrar com Facebook",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
