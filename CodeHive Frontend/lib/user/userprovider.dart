import 'package:collab_code_editor/user/usermodel.dart';
import 'package:flutter/material.dart';

class Userprovider extends ChangeNotifier{

  UserModel? currentUser;

  void setUser(UserModel user){
    currentUser = user;
    debugPrint('UserProvider Set user function called');
    debugPrint(currentUser?.name.toString());
    debugPrint(currentUser?.email.toString());
    debugPrint(currentUser?.id.toString());
    notifyListeners();
  }

  void cleanUser(){
    currentUser = null;
    notifyListeners();
  }
}