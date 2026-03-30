import 'dart:convert';
import 'package:collab_code_editor/services/api_url.dart';
import 'package:collab_code_editor/services/authservices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExecutionServices {

  final baseUrl = BaseUrl.baseUrl;

  Future<Map<String, dynamic>?> executeCode(String code, String input) async{
    try{
      final prefs = await SharedPreferences.getInstance();
         String? token = prefs.getString(AuthServices.AUTHKEY);

          if(token != null && token.isNotEmpty){
              debugPrint('token found');
              // debugPrint("${AuthServices.AUTHKEY} = $token");

              // here we store our response from the api hit in a response named varialbe
              http.Response response = await http.post(Uri.parse("$baseUrl/api/v1/execute"),
              headers: {
                "Content-Type": "application/json",
                "Authorization" : "Bearer $token"
              },
              body: jsonEncode({
                "code" : code,
                "input" : input
              })
              );
              debugPrint(response.statusCode.toString());

              if(response.statusCode == 200){
                Map<String,dynamic> data = jsonDecode(response.body);
                // debugPrint(data.toString());
                return data;
              }
              if(response.statusCode == 400){
                Map<String,dynamic> data = jsonDecode(response.body);
                // debugPrint(data.toString());
                return data;
              }
                else{
                return null;
                }
              }
              else{
                debugPrint('Token not found');
                return null;
                } 
    }catch (e) {
        debugPrint('Error in Execution Code Serivce');
        debugPrint(e.toString());
        return null;
    }
  }
}