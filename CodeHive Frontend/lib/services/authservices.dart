import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:collab_code_editor/services/api_url.dart';
import 'package:collab_code_editor/user/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices{
  // ignore: constant_identifier_names
  static const String AUTHKEY = "auth_token";
        final baseUrl = BaseUrl.baseUrl;

    Future<bool> signupService(
      String authNameController,
      String authEmailController,
      String authPasswordController,
      String authConfirmPasswordController,
      ) async{

        final signupURL = Uri.parse("$baseUrl/api/v1/signup");

        Map<String,dynamic> signupData = {
          "name" : authNameController.trim(),
          "email" : authEmailController.trim(),
          "password": authPasswordController.trim(),
          "confirmPassword": authConfirmPasswordController.trim()
        };


        final response = await http.post(
          signupURL,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(signupData)
        );

      debugPrint(response.statusCode.toString());
      debugPrint(response.body);

        if(response.statusCode == 200){
          Map<String,dynamic> signupinfo = jsonDecode(response.body);
          String? token = signupinfo['token'];

          // storing the token in app data
          if(token != null && token.isNotEmpty){
          debugPrint(" token = $token");

          final prefs = await SharedPreferences.getInstance();
          prefs.setString(AuthServices.AUTHKEY, token);
            return true;
          }else{
          debugPrint('No Token Available');
          return false;
          }
        }else{
          return false;
        }
        
      

      }


    
  

    Future<bool> loginService(
    String authEmailController,
    String authPasswordController,
    ) async{

      final loginURL = Uri.parse("$baseUrl/api/v1/login");

      Map<String,dynamic> signupData = {
        "email" : authEmailController.trim(),
        "password": authPasswordController.trim(),
      };


      final response = await http.post(
        loginURL,
         headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(signupData)
      );

      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());

      if(response.statusCode == 200){
        Map<String,dynamic> loginData = jsonDecode(response.body);
        String? token = loginData['token'];


        // storing the token in app data
        if(token != null && token.isNotEmpty){

        debugPrint(" token = $token");
        
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(AuthServices.AUTHKEY, token);
        return true;

        }else{
        debugPrint('No Token Available');
        return false;
        }
      }else{
        return false;
      }
    }

    Future<UserModel?> isLoggedInService() async{

      try {
         final prefs = await SharedPreferences.getInstance();
         String? token = prefs.getString(AuthServices.AUTHKEY);

          if(token != null && token.isNotEmpty){
              debugPrint('token found');
              debugPrint("${AuthServices.AUTHKEY} = $token");

              // here we store our response from the api hit in a response named varialbe
              http.Response response = await http.get(Uri.parse("$baseUrl/api/v1/me"),
              headers: {
                "Authorization" : "Bearer $token"
              }
              );
              debugPrint(response.statusCode.toString());
              

              if(response.statusCode == 200){

                Map<String,dynamic> userData = jsonDecode(response.body);
                // debugPrint(userData['user'].toString());

                return UserModel.fromJson(userData['user']);
              }else{
                return null;
              }
          }
              else{
                debugPrint('token not found');
                return null;
                } 
    }catch (e) {
        debugPrint(e.toString());
        return null;
      }
  }
   

  Future<bool> logoutService() async{
    final prefs = await SharedPreferences.getInstance();
    
    if(await prefs.remove(AuthServices.AUTHKEY)){
      
      return true;

    }else{
      return false;
    }
  }

}