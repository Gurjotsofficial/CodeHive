import 'dart:convert';
import 'package:collab_code_editor/services/api_url.dart';
import 'package:collab_code_editor/services/authservices.dart';
import 'package:collab_code_editor/workspace/workspacemodel.dart';
import 'package:collab_code_editor/workspace_document/workspacedocumentmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkspaceDocumentsservices {
  final baseUrl = BaseUrl.baseUrl;

  Future<List<WorkspaceDocumentModel>> fetchWorkspaceDocuments(String workspaceId) async{
    debugPrint('Fetch Document Service Called');
    try {
      final prefs = await SharedPreferences.getInstance();
         String? token = prefs.getString(AuthServices.AUTHKEY);

          if(token != null && token.isNotEmpty){
              debugPrint('token found');
              // debugPrint("${AuthServices.AUTHKEY} = $token");

              // here we store our response from the api hit in a response named varialbe
              http.Response response = await http.get(Uri.parse("$baseUrl/api/v1/getWorkspaceDocument/$workspaceId"),
              headers: {
                "Content-Type": "application/json",
                "Authorization" : "Bearer $token"
              }
              );
              debugPrint(response.statusCode.toString());
              

              if(response.statusCode == 200){
                final data = jsonDecode(response.body);
                List workspaceDocumentJson = data['document'];
                
                debugPrint('Fetching Documents');
                // why did we do this
                List<WorkspaceDocumentModel> documents  = workspaceDocumentJson.map((json) => WorkspaceDocumentModel.fromJson(json)).toList();
                debugPrint('Documents Fetched');
                return documents;
              }
                else{
                return [];
                }
              }
              else{
                debugPrint('token not found');
                return [];
                } 
    } catch (e) {
        debugPrint(e.toString());
        return [];
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


   Future<bool> updateWorkspaceDocument(String documentID, String newContent) async{
    debugPrint(documentID);
    debugPrint(newContent);
    try {
      final prefs = await SharedPreferences.getInstance();
         String? token = prefs.getString(AuthServices.AUTHKEY);

          if(token != null && token.isNotEmpty){
              debugPrint('token found');
              // debugPrint("${AuthServices.AUTHKEY} = $token");

              // here we store our response from the api hit in a response named varialbe
              http.Response response = await http.put(Uri.parse("$baseUrl/api/v1/updateWorkspaceDocument/$documentID"),
              headers: {
                "Content-Type": "application/json",
                "Authorization" : "Bearer $token"
              },
              body: jsonEncode({
                "content" : newContent,
              })
              );
              debugPrint(response.statusCode.toString());

              // if(response.statusCode == 404){
              //   final data = jsonDecode(response.body);
              //   debugPrint(data.toString());
              //   return false;
              // }
              if(response.statusCode == 200){
                final data = jsonDecode(response.body);
                debugPrint(data.toString());
                return true;
              }
                else{
                return false;
                }
              }
              else{
                debugPrint('token not found');
                return false;
                } 
    } catch (e) {
        debugPrint('Error in Create Workspace Serivce');
        debugPrint(e.toString());
        return false;
    }
  }




// WE will use this function or service to update our workspace


// Service to create a workspace document in the workspace
Future<WorkspaceDocumentModel?> createDocument(
  String workspaceId,
  String name,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AuthServices.AUTHKEY);

    if (token != null && token.isNotEmpty) {

      http.Response response = await http.post(
        Uri.parse(
          "$baseUrl/api/v1/createWorkspaceDocument/$workspaceId",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
        }),
      );

      debugPrint(response.statusCode.toString());
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final docJson = data["New_Document"];

        return WorkspaceDocumentModel.fromJson(docJson);
        
      } else {
        debugPrint("Failed to create document");
        return null;
      }
    } else {
      debugPrint("Token not found");
      return null;
    }
  } catch (e) {
    debugPrint("Create Document Service Error");
    debugPrint(e.toString());
    return null;
  }
}

/// DELETE WORKSPACE DOCUMENT SERVICE
Future<bool> deleteWorkspaceDocument(String documentId) async{
    debugPrint('Delete Document Service Called');
    try {
      final prefs = await SharedPreferences.getInstance();
         String? token = prefs.getString(AuthServices.AUTHKEY);

          if(token != null && token.isNotEmpty){
              debugPrint('token found');
              // debugPrint("${AuthServices.AUTHKEY} = $token");

              // here we store our response from the api hit in a response named varialbe
              http.Response response = await http.delete(Uri.parse("$baseUrl/api/v1/deleteWorkspaceDocument/$documentId"),
              headers: {
                "Content-Type": "application/json",
                "Authorization" : "Bearer $token"
              }
              );
              debugPrint(response.statusCode.toString());
              

              if(response.statusCode == 200){
                final data = response.body.toString();
                debugPrint(data);
                debugPrint('Documents Deleted');
                return true;
              }
                else{
                  debugPrint('Error in deleting the document');
                return false;
                }
              }
              else{
                debugPrint('token not found');
                return false;
                } 
    } catch (e) {
        debugPrint(e.toString());
        return false;
    }
  }



} // Class Ends Here

