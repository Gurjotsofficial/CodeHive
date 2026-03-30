import 'dart:convert';
import 'package:collab_code_editor/services/api_url.dart';
import 'package:collab_code_editor/services/authservices.dart';
import 'package:collab_code_editor/workspace/workspacemodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Workspaceservices {
  final baseUrl = BaseUrl.baseUrl;

  Future<List<WorkspaceModel>?> fetchWorkspaces() async{
    try {
      final prefs = await SharedPreferences.getInstance();
         String? token = prefs.getString(AuthServices.AUTHKEY);

          if(token != null && token.isNotEmpty){
              debugPrint('token found');
              // debugPrint("${AuthServices.AUTHKEY} = $token");

              // here we store our response from the api hit in a response named varialbe
              http.Response response = await http.get(Uri.parse("$baseUrl/api/v1/get_workspace"),
              headers: {
                "Authorization" : "Bearer $token"
              }
              );
              debugPrint(response.statusCode.toString());
              

              if(response.statusCode == 200){
                final data = jsonDecode(response.body);
                List workspacesJson = data['workspace'];
                

                // why did we do this
                List<WorkspaceModel> workspaces = workspacesJson.map((json) => WorkspaceModel.fromJson(json)).toList();
                return workspaces;
              }
                else{
                return null;
                }
              }
              else{
                debugPrint('token not found');
                return null;
                } 
    } catch (e) {
        debugPrint(e.toString());
        return null;
    }
  }


// we will use this function to create a new workspace
  Future<WorkspaceModel?> createWorkspace(String workspaceName) async{
    try {
      final prefs = await SharedPreferences.getInstance();
         String? token = prefs.getString(AuthServices.AUTHKEY);

          if(token != null && token.isNotEmpty){
              debugPrint('token found');
              // debugPrint("${AuthServices.AUTHKEY} = $token");

              // here we store our response from the api hit in a response named varialbe
              http.Response response = await http.post(Uri.parse("$baseUrl/api/v1/create_workspace"),
              headers: {
                "Content-Type": "application/json",
                "Authorization" : "Bearer $token"
              },
              body: jsonEncode({
                "name" : workspaceName,
              })
              );
              debugPrint(response.statusCode.toString());

              if(response.statusCode == 201){
                final data = jsonDecode(response.body);
                debugPrint(data.toString());
                WorkspaceModel? createdWorkspace = WorkspaceModel.fromJson(data['workspace']);
                return createdWorkspace;
              }
                else{
                return null;
                }
              }
              else{
                debugPrint('token not found');
                return null;
                } 
    } catch (e) {
        debugPrint('Error in Create Workspace Serivce');
        debugPrint(e.toString());
        return null;
    }
  }


Future<WorkspaceModel?> joinRoomService(String workspaceId) async{
    try {
      final prefs = await SharedPreferences.getInstance();
         String? token = prefs.getString(AuthServices.AUTHKEY);

          if(token != null && token.isNotEmpty){
              debugPrint('token found');
              debugPrint('This is join room function');
              // debugPrint("${AuthServices.AUTHKEY} = $token");

              // here we store our response from the api hit in a response named varialbe
              http.Response response = await http.get(Uri.parse("$baseUrl/api/v1/join_room/$workspaceId"),
              headers: {
                "Authorization" : "Bearer $token"
              }
              );
              debugPrint(response.statusCode.toString());
              
              if(response.statusCode == 404){
                debugPrint(response.body.toString());
                return null;
              }

              if(response.statusCode == 200){
                final data = jsonDecode(response.body);
                final workspaceJson = data['workspace'];
                

                // why did we do this
                final workspace = WorkspaceModel.fromJson(workspaceJson);
                return workspace;
              }
                else{
                return null;
                }
              }
              else{
                debugPrint('token not found');
                return null;
                } 
    } catch (e) {
        debugPrint(e.toString());
        return null;
    }
  }

}