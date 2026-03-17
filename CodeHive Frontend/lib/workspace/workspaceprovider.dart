import 'package:collab_code_editor/workspace/workspacemodel.dart';
import 'package:collab_code_editor/workspace/workspaceservices.dart';
import 'package:flutter/material.dart';

class Workspaceprovider extends ChangeNotifier{

  List<WorkspaceModel> currentWorkspaces = [];

  void setWorkspaces(List<WorkspaceModel> workspaces){
    currentWorkspaces = workspaces;
    notifyListeners();
  }

  void cleanWorkspace(){
    currentWorkspaces = [];
    notifyListeners();
  }

  Future<bool> createWorkspace(String workspaceName) async{
    debugPrint(workspaceName);
    try{
      final responseWorkspace = await Workspaceservices().createWorkspace(workspaceName);
    if(responseWorkspace != null){
      currentWorkspaces.add(responseWorkspace);
    notifyListeners();
    return true;
    }else{
      debugPrint('Null Was Returned');
      return false;
    }
    }catch(e){
      debugPrint(e.toString());
      return false;
    }

  }
}