import 'package:collab_code_editor/workspace_document/workspacedocumentmodel.dart';
import 'package:collab_code_editor/workspace_document/workspacedocumentservices.dart';
import 'package:flutter/material.dart';

class WorkspaceDocumentProvider extends ChangeNotifier {
  List<WorkspaceDocumentModel> documents = [];
  WorkspaceDocumentModel? activeDocument;
  bool isLoading = false;

  Future<void> fetchDocuments(String workspaceId) async {
  isLoading = true;
  notifyListeners();

  final docs = await WorkspaceDocumentsservices().fetchWorkspaceDocuments(workspaceId);
  debugPrint('Fetch Documents Function Called');
  documents = docs;
  if(documents.isEmpty){
    activeDocument = null;
  }else{
    debugPrint('Fetching Active Document');
    activeDocument = documents[0];
    debugPrint("Name = ${activeDocument!.name.toString()}");
    debugPrint("Id = ${activeDocument!.id.toString()}");
  }
  // activeDocument = documents.isNotEmpty ? documents.first : null;

  isLoading = false;
  notifyListeners();
}

    void updateLocalContent(String newContent) {
      if (activeDocument != null) {
        activeDocument = WorkspaceDocumentModel(
          id: activeDocument!.id,
          name: activeDocument!.name,
          content: newContent,
          updatedAt: activeDocument!.updatedAt,
        );
        notifyListeners();
      }
    }

    // Provider Function to update content of the document at backend
    Future<void> saveDocumentContent(String documentId, String newContent) async {

    final success = await WorkspaceDocumentsservices().updateWorkspaceDocument(documentId,newContent);
    debugPrint('save Documents Function Called');
    if(success){
      debugPrint("Document Updated Successfully");
    }else{
      debugPrint('Error in updating the document');
    }
    }


  void cleanWorkspaceDocument(){
    documents = [];
    activeDocument = null;
    notifyListeners();
  }

  Future<bool> createDocument(String workspaceId,String name,)async {
  try {
    final newDoc = await WorkspaceDocumentsservices().createDocument(workspaceId, name);

    if (newDoc != null) {
      documents.add(newDoc);
      activeDocument = newDoc;
      debugPrint("Document Created Successfully");
      debugPrint('Document = ${activeDocument!.name.toString()}');
      // debugPrint(documents.map((item) => '\nDocument : ${item.name}').toString());
      notifyListeners();
      return true;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint("Provider Create Document Error");
    debugPrint(e.toString());
    return false;
  }
}
}