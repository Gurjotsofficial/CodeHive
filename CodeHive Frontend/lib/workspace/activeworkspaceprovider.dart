import 'package:collab_code_editor/workspace/workspacemodel.dart';
import 'package:flutter/material.dart';

class ActiveWorkspaceProvider extends ChangeNotifier{
    WorkspaceModel? activeWorkspace;

    void setActiveWorkspace(WorkspaceModel workspace){
      activeWorkspace = workspace;
      debugPrint('\nSet Active Workspace Function Called');
      debugPrint(activeWorkspace?.id.toString());
      debugPrint(activeWorkspace?.name.toString());
      debugPrint(activeWorkspace?.createdAt.toString());

      notifyListeners();
    }

    void clearActiveWorkspace(){
      activeWorkspace = null;

      notifyListeners();
    }
}