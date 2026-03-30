import 'package:collab_code_editor/services/authservices.dart';
import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/workspace/workspaceprovider.dart';
import 'package:collab_code_editor/services/workspaceservices.dart';
// import 'package:collab_code_editor/user/userprovider.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier{

  GlobalKey<FormState> authFormKey = GlobalKey();

  bool? isAuthenticated;

  Future<bool> login(String authEmailController, String authPasswordController) async{

   final success = await AuthServices().loginService(authEmailController, authPasswordController);

   return success;

  }

  Future<bool> signUp(
    String authNameController,
    String authEmailController,
    String authPasswordController,
    String authConfirmPasswordController,
  )async{

   final success = await AuthServices().signupService(authNameController, authEmailController, authPasswordController, authConfirmPasswordController);

   return success;

  }

  Future<void> isLoggedIn(Userprovider userprovider, Workspaceprovider workspaceprovider) async{
    debugPrint('authprovider isLoggedIn function is running');
    final user = await AuthServices().isLoggedInService();

    if(user != null){
      // debugPrint(user.email.toString());
      isAuthenticated = true;
      userprovider.setUser(user);

    final workspaces = await Workspaceservices().fetchWorkspaces();
    debugPrint('Workspaces Fetched');
    if(workspaces != null && workspaces.isNotEmpty){
      workspaceprovider.setWorkspaces(workspaces);
    }
    }else{  
    isAuthenticated = false;
    userprovider.cleanUser();
    workspaceprovider.cleanWorkspace();
    }
    notifyListeners();


  }

  void logout() async{
    final success = await AuthServices().logoutService();

    // if(success){
      isAuthenticated = !success;
    // }
    notifyListeners();

  }
}