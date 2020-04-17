
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';


class UserModel extends Model{

  FirebaseAuth _auth = FirebaseAuth.instance; // SALVA EM UMA VARIAVEL A INSTANCIA DE AUTENTICACAO DO FIREBASE
  FirebaseUser firebaseUser; //ARMAZENA O ID DO USUARIO
  Map<String, dynamic> userData = Map(); // ARMAZENA ALGUNS DADOS DO USUARIO
//  usuário atual
  bool isLoading = false;


  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }

  void signUp( { @required Map<String, dynamic> userData ,@required String pass,@required VoidCallback onSuccess,@required VoidCallback onFail , @required File image,  }){
      isLoading = true; //FALA Q ESTA CARREGANDO
      notifyListeners(); // NOTIFICA A INTEREFACE

      _auth.createUserWithEmailAndPassword(
          email: userData['email'],
          password: pass
      ).then((user) async{ //SE FUNCIONAR
        print('entrou salar usuário');
        firebaseUser = user.user;
        await _saveUserData(userData);
        if(image != null){
          String _uploadedFileURL = await uploadFile(image, firebaseUser.uid);
          Map<String, dynamic> img = {
            'img': _uploadedFileURL
          };
          // pega os dados do usuario e salva no firebase pra usar
          await Firestore.instance.collection('users').document(firebaseUser.uid).updateData(img);
        }

        onSuccess();
        isLoading = false;
        notifyListeners();
      }).catchError((signUpError){ // SE NAO FUNCIONAR
        if(signUpError is PlatformException){
          if(signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE' || signUpError.code == 'ERROR_INVALID_EMAIL'){
            onFail();
          }
        }
        print(signUpError);
        isLoading = false;
        notifyListeners();

      });
  }


  Future<String> uploadFile(File _image, String uid) async {
    print('carregando imagem');
    final FirebaseStorage _storage =
    FirebaseStorage(storageBucket: 'gs://loja-f7ade.appspot.com');
    StorageReference storageReference =
    _storage.ref().child('users/$uid/${DateTime.now()}.png');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    String url;
    await storageReference.getDownloadURL().then((fileURL) {
      url =  fileURL;
    });
    return url;
  }




  void signIn({ @required String email, @required String pass, @required VoidCallback onSuccess, @required VoidCallback onFail} ) async{
    isLoading = true;
    notifyListeners();
    _auth.signInWithEmailAndPassword(email: email, password: pass).then(
        (user) async{
          firebaseUser = user.user;

            await _loadCurrentUser();
            onSuccess();
            isLoading = false;
            notifyListeners();
        }).catchError((signInError){
          if(signInError is PlatformException){
            if(signInError.code == 'ERROR_USER_NOT_FOUND' || signInError.code == 'ERROR_WRONG_PASSWORD'){
              onFail();
            }
          }
          print(signInError);
          isLoading = false;
          notifyListeners();
    });
  }



  void recoverPass(String email){
    _auth.sendPasswordResetEmail(email: email);
  }

  void signOut() async{
    await _auth.signOut();
    userData = Map();
    firebaseUser = null;
    notifyListeners();
  }

  void isGooglein(FirebaseUser googleUser){
    firebaseUser = googleUser;
  }

  bool isLoggedIn(){
    return firebaseUser !=null;
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async{
    this.userData  = userData;
    print(userData);
    await Firestore.instance.collection('users').document(firebaseUser.uid).setData(userData);
    print('deu certo');
  }
  Future<Null> _loadCurrentUser() async{
    if(firebaseUser == null){
      firebaseUser = await _auth.currentUser();
    }
    if(firebaseUser != null){
      if(userData['name'] == null){
        DocumentSnapshot docUser = await Firestore.instance.collection('users').document(firebaseUser.uid).get();
        userData = docUser.data;
        notifyListeners();
      }
    }
  }
}