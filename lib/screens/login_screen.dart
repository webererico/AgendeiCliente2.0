import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/models/user_model.dart';
import 'package:agendei_cliente/screens/home_screen.dart';
import 'package:agendei_cliente/screens/register_screen.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:apple_sign_in/apple_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color _cor1 = Color.fromARGB(255, 25, 25, 112);
  final Color _cor2 = Color.fromARGB(255, 79, 79, 216);
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String name;
  String email;
  String imageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

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
    Firestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .then((document) {
      if (document.exists) {
        print('usuario ja existe');
      } else {
        name = user.displayName;
        email = user.email;
        imageUrl = user.photoUrl;
        Map<String, dynamic> userData = {
          'name': user.displayName,
          'email': user.email,
          'img': user.photoUrl
        };

        Firestore.instance
            .collection('users')
            .document(user.uid)
            .setData(userData);
        print('novo usuário criado');
      }
    });
    return 'signInWithGoogle succeeded: $user';
  }

//  void appleLogIn() async {
//    if(await AppleSignIn.isCilable()) {
//      final authorizationResult result = await
//      AppleSignIn.performRequests([
//        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
//      ]);
//    }else{
//      print('Apple SignIn is not available for your device');
//    }
//  }

//  @override
//  void initState() {
////    if(Platafo){                                                      //check for ios if developing for both android & ios
////      AppleSignIn.onCredentialRevoked.listen((_) {
////        print("Credentials revoked");
////      });
////    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_cor1, _cor2],
                  ),
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(90))),
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
                            size: 90,
                            color: Colors.white,
                          ),
                          Text(
                            'Agendei',
                            style: TextStyle(
                                fontSize: 42.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      )),
                  Spacer(),
                ],
              ),
            ),
            ScopedModelDescendant<UserModel>(builder: (context, child, model) {
              if (model.isLoading) {
                return Center(
                  heightFactor: 10,
                  child: CircularProgressIndicator(),
                );
              }
              return Form(
                  key: _formKey,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 45,
                          padding: EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ]),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.email,
                                color: Colors.grey,
                              ),
                              hintText: 'Email',
                            ),
                            validator: (text) {
                              if (text.isEmpty || !text.contains("@")) {
                                return ("E-mail inválido");
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 45,
                          margin: EdgeInsets.only(top: 32),
                          padding: EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ]),
                          child: TextFormField(
                            controller: _passController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.vpn_key,
                                color: Colors.grey,
                              ),
                              hintText: 'Senha',
                            ),
                            obscureText: true,
                            validator: (text) {
                              if (text.isEmpty || text.length < 6) {
                                return "Senha inválida";
                              } else {
                                return 'ok';
                              }
                            },
                          ),
                        ),

//                  Spacer(),
                        SizedBox(
                          height: 70.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SignInButton(
                                Buttons.Apple,
                                mini: true,
                                onPressed: () {
//                                  appleLogIn();
                                },
                              ),
                              SignInButton(
                                Buttons.Facebook,
                                mini: true,
                                onPressed: () {
//                          _showButtonPressDialog(context, 'Tumblr (mini)');
                                },
                              ),
                              Container(
                                height: 38.0,
                                width: 180.0,
                                child: SignInButton(
                                  Buttons.Google,
                                  text: "Entrar com Google",
                                  onPressed: () {
                                    Center(
                                      heightFactor: 10,
                                      child: CircularProgressIndicator(),
                                    );
                                    signInWithGoogle().whenComplete(() {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return HomeScreen();
                                          },
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 10)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_cor1, _cor2],
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100))),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: RaisedButton(
                                    child: Text(
                                      "Criar conta".toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    textColor: Colors.white,
                                    color: Colors.transparent,
                                    elevation: 0.0,
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterScreen()));
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 20.0)),
                            Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width / 3.5,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_cor1, _cor2],
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Align(
                                alignment: Alignment.center,
                                child: RaisedButton(
                                  child: Text(
                                    "Entrar".toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  textColor: Colors.white,
                                  color: Colors.transparent,
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {}
                                    model.signIn(
                                        email: _emailController.text,
                                        pass: _passController.text,
                                        onSuccess: _onSuccess,
                                        onFail: _onFail);
                                  },
                                  elevation: 0.0,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 0.0, right: 0.0),
                            child: FlatButton(
                              onPressed: () {
                                if (_emailController.text.isEmpty) {
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'O campo e-mail está vazio ou é inválido. Por favor, informe seu e-mail para recuperar sua senha'),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                } else {
                                  model.recoverPass(_emailController.text);
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Confira seu e-mail. Enviamos um e-mail de recuperação de senha para você. :D'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "Esqueci minha senha",
                                textAlign: TextAlign.center,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            }),
          ],
        ),
      ),
    );
  }

  void _onSuccess() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Senha errada ou o usuário não existe. Confira seu e-mail e senha.'),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
