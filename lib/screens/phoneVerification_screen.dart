//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneVerificationScreen extends StatefulWidget {
  String uidUser;
  PhoneVerificationScreen({this.uidUser, Key key}): super(key : key);
  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  TextEditingController _smsCodeController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  String verificationId;
  bool sent = false;

  @override
  void initState() {
    super.initState();
  }

  /// Sends the code to the specified phone number.
  Future<void> _sendCodeToPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      print('sucesso');
//      if(verificationId == _smsCodeController.text){
//        setState(() {
//
//        });
//        print('ok');
//        Map<String, dynamic> userNumber = {
//          'phoneFinal': _phoneNumberController.text
//        };
//        Firestore.instance.collection('users').document(widget.uidUser).updateData(userNumber);
//      }

    };

    final PhoneVerificationFailed verificationFailed = (AuthException authException) {
      setState(() {
        print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');}
      );
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      print("code sent to " + _phoneNumberController.text);
      print('code: '+verificationId);
      setState(() {
        sent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      print("time out");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _signInWithPhoneNumber(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode);
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    AuthResult newUser = await FirebaseAuth.instance.signInWithCredential(credential);
    print(newUser.user.uid);
    user.linkWithCredential(credential);
    print('numero verificado');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validar telefone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(height: 50.0,),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixText: "+55",
                  border: OutlineInputBorder()),
            ),
            FlatButton(
              child: sent == true ? Text('Reenviar código'): Text("Receber código"),
              onPressed: () {
                _phoneNumberController.text ='+55'+_phoneNumberController.text;
                print(_phoneNumberController.text);
                _sendCodeToPhoneNumber();
              },
            ),
            Visibility(
              visible: sent == true ? true : false,
              child: TextField(
                controller: _smsCodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder()
                ),
              ),
            ),
            Visibility(
              visible: sent = true,
              child: FlatButton(
                child: Text("Acessar"),
                onPressed: () {
                   FirebaseAuth.instance.currentUser().then((value){
                     print(value.uid);
                   });
                },
              ),
            ),
          ], // Widget
        ),
      ), // Column ,
    );
  }
}
