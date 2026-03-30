import 'package:collab_code_editor/services/execution_services.dart';
import 'package:flutter/material.dart';

class ExecutionProvider extends ChangeNotifier {
  String output = "";
  String error = "";
  bool isExecuting = false;

  Future<void> runCode(String code, String input) async {
    if(isExecuting){
      return;
      }

    output = "";
    error = "";

    isExecuting = true;
    notifyListeners();

    final result = await ExecutionServices().executeCode(code, input);
    
   if (result == null) {
    output = "";
    error = "Execution failed. Please try again.";
    } else {
      output = result["output"] ?? "";
      error = result["error"] ?? "";
      
      debugPrint(output);
      debugPrint(error);
    }
    isExecuting = false;
    notifyListeners();
  }


  void clearExecution(){
  
    output = "";
    error = "";
    notifyListeners();
    
  }

}