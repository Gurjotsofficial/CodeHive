import 'dart:async';
import 'package:collab_code_editor/execution/execution_provider.dart';
import 'package:collab_code_editor/presence/presenceprovider.dart';
import 'package:collab_code_editor/services/socket_services.dart';
// import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/workspace/activeworkspaceprovider.dart';
import 'package:collab_code_editor/workspace_document/workspacedocumentprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:provider/provider.dart';
// import 'package:highlight/languages/javascript.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart' as monokai;

class Workspaceshell extends StatefulWidget {
  const Workspaceshell({super.key});

  @override
  State<Workspaceshell> createState() => _WorkspaceshellState();
}

class _WorkspaceshellState extends State<Workspaceshell> {

    late CodeController codeController; // this is a codecontroller for a code field just like a textfieldcontroller for a text field
    
    TextEditingController inputController = TextEditingController();
    TextEditingController createDocumentNameController = TextEditingController();

    late SocketService socketService;
    Timer? _debounce;

//    @override
// void initState() {
//   super.initState();

//   // initialising the code controller
//   codeController = CodeController(
//     text: "",
//     language: javascript,
//   );

// codeController.addListener(() {

//   if (_applyingRemoteChange) return;

//   final value = codeController.text;
//   final provider = context.read<WorkspaceDocumentProvider>();

//   // Do not emit if this text came from the network
//   if (value == _lastRemoteText) return;

//   if (_debounce?.isActive ?? false) {
//     _debounce!.cancel();
//   }

//   _debounce = Timer(const Duration(milliseconds: 200), () {

//     if (provider.activeDocument != null) {

//       socketService.emitCodeChange(
//         provider.activeDocument!.id,
//         value,
//       );

//     }

//   });

// });

//   socketService = SocketService();
//   socketService.connect();

//   WidgetsBinding.instance.addPostFrameCallback((_) async {

//     // Fetching Providers
//     final workspaceProvider = context.read<ActiveWorkspaceProvider>();
//     final documentProvider = context.read<WorkspaceDocumentProvider>();
//     final presenceProvider = context.read<PresenceProvider>();
//     final userprovider = context.read<Userprovider>(); 
    
//     // Fetching Active Workspace Id
//     final workspaceId = workspaceProvider.activeWorkspace!.id;

//     // fetch documents
//     await documentProvider.fetchDocuments(workspaceId);

//     final activeDoc = documentProvider.activeDocument;
//       if (activeDoc != null) {

//         // load editor text
//         codeController.text = activeDoc.content;

//         // join socket room
//         final username = userprovider.currentUser!.name;

//         socketService.joinDocument(
//           activeDoc.id,
//           username,
//         );

//         currentDocumentId = activeDoc.id;
//      }

//     // initialising the code editor with the active document's loaded value
//     // if (activeDoc != null) {
      
//     //   codeController.text = activeDoc.content;
//     // }

//     // listen for code changes
//     // socketService.listenCodeChange((content) {

//     //   final oldCursorPosition =
//     //       codeController.selection.baseOffset;

//     //   documentProvider.updateLocalContent(content);

//     //   codeController.text = content;

//     //   if (oldCursorPosition <= codeController.text.length) {
//     //     codeController.selection =
//     //         TextSelection.collapsed(
//     //             offset: oldCursorPosition);
//     //   }

//     //   if (codeController.text != content) {
//     //     documentProvider.updateLocalContent(content);
//     //     codeController.text = content;
//     //   }

//     // });
//   socketService.listenCodeChange((content) {

//   if (codeController.text == content) return;

//   _debounce?.cancel();

//   final currentSelection = codeController.selection;

//   _applyingRemoteChange = true;

//   codeController.value = codeController.value.copyWith(
//     text: content,
//     selection: currentSelection.baseOffset <= content.length
//         ? currentSelection
//         : TextSelection.collapsed(offset: content.length),
//   );

//   // remember the remote text
//   _lastRemoteText = content;

//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     _applyingRemoteChange = false;
//   });

// });

//     // listen for presence updates
//     socketService.listenPresence((users) {

//       presenceProvider.updatePresence(users);

//     });

//   });

// }
  

    @override
    void dispose() {
      codeController.dispose();
      inputController.dispose();
      createDocumentNameController.dispose();
      socketService.disconnect();
      _debounce?.cancel();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {

    final activeWorkspaceProvider = context.watch<ActiveWorkspaceProvider>();
    final activeDocumentProvider = context.watch<WorkspaceDocumentProvider>();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//     final activeDoc = activeDocumentProvider.activeDocument;
//     if (activeDoc == null) return;
//     final username = context.read<Userprovider>().currentUser!.name;
//     final newDocId = activeDoc.id;
//     if (currentDocumentId != newDocId) {
//       if (currentDocumentId != null) {
//         socketService.leaveDocument(currentDocumentId!);
//       }
//       socketService.joinDocument(newDocId, username);
//       currentDocumentId = newDocId;
//     }
// });


      if(activeDocumentProvider.isLoading == true){
        return  const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      )
      );
      }else{
      return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[200],
          title: Text(
            activeWorkspaceProvider.activeWorkspace!.name,
            style: const TextStyle(fontSize: 22, color: Colors.black),
          ),
          actions: [
            IconButton(
              onPressed: () {
                if(activeDocumentProvider.activeDocument != null){
                activeDocumentProvider.saveDocumentContent(activeDocumentProvider.activeDocument!.id, codeController.text);
                }
              },
              icon: const Icon(Icons.save, color: Colors.black),
            ),
            IconButton(
              onPressed: () {if(activeDocumentProvider.activeDocument != null){

              
                final code = codeController.text;
                final input = inputController.text;

                context.read<ExecutionProvider>().runCode(code, input);
              }else{
                return;
                }
              },
              icon: const Icon(Icons.play_arrow, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.swap_vert_circle_outlined,
                  color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                // showCreateDocumentDialog();
              },
              icon: const Icon(Icons.add_box_outlined,
                  color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                activeWorkspaceProvider.clearActiveWorkspace();
                activeDocumentProvider.cleanWorkspaceDocument();
                context.read<ExecutionProvider>().clearExecution();
                socketService.disconnect();            
                // socketService.leaveDocument(currentDocumentId!);
              },
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ],
        ),
        body: Row(
          children: [
            // LEFT SIDEBAR (Members)
            Container(
              width: 220,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  // Consumer<PresenceProvider>(
                  //   builder: (context, presence, child) {
                  //     return const 
                      Text(
                            "Members",
                            style: TextStyle(fontSize: 18),
                          ),

                   Consumer<PresenceProvider>(
                    builder: (context, presence, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          ...presence.activeUsers.map(
                            (user) => Text("• $user",
                            style: TextStyle(fontSize: 16),
                            )
                          )
                        ],
                      );
                    },
                    )
                ],
              ),
            ),

            // RIGHT MAIN AREA
            Expanded(
              child: Column(
                children: [
                  // EDITOR AREA (MOST SPACE)
                  Expanded(
                    flex: 7,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: activeDocumentProvider.activeDocument == null
                              ? const Text('No Document Exists in this Workspace',
                              style: TextStyle(fontFamily: 'monospace'),
                              )
                              : _buildEditor(activeDocumentProvider),
                  ),
                  ),
                  // INPUT + OUTPUT AREA (REMAINING HEIGHT)
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black, width: 1.2),
                            ),
                            child:
                                // 
                                Consumer<ExecutionProvider>(
                                builder: (context, execProvider, _) {

                                  if (execProvider.isExecuting) {
                                    return Center(child: CircularProgressIndicator());
                                  }

                                  if (execProvider.error.isNotEmpty) {
                                    return SingleChildScrollView(
                                      child: SelectableText(
                                        execProvider.error,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  }
                                 if(execProvider.output.isNotEmpty){
                                  return SingleChildScrollView(child: SelectableText(execProvider.output));
                                 } 
                                 return SelectableText("Outputs Will Appear Here");
                                },
                              )
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black, width: 1.2),
                            ),
                            child:
                                TextField(
                                  controller: inputController,
                                  maxLines: null,
                                  expands: true,
                                  decoration: const InputDecoration(
                                    helperStyle:  TextStyle(fontFamily: 'monospace'),
                                    hintText: "Kindly Pass Your Input Here!"
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      }
    }











// METHODS
Widget _buildEditor(WorkspaceDocumentProvider provider) {

  if (provider.activeDocument == null) {
    return const Text("No Document Exists in this Workspace");
  }

  return CodeTheme(
    data: CodeThemeData(styles: monokai.monokaiSublimeTheme),
    child: CodeField(
      controller: codeController,
      expands: true,
      textStyle: const TextStyle(
       fontFamily: 'monospace',
      fontSize: 14,
      ),
    ),
  );
}
    // decoration: InputDecoration(
    // helperStyle:  
    // textStyle: TextStyle(fontFamily: 'monospace'),
    //  hintText: "Kindly Write Your Code Here!"
    // ),  


// void showCreateDocumentDialog() {

//   showDialog(
//     context: context,
//     builder: (context) {

//       return AlertDialog(
//         title: const Text("Create New File"),

//         content: TextField(
//           controller: createDocumentNameController,
//           decoration: const InputDecoration(
//             hintText: "Enter file name (example: main.js)",
//           ),
//         ),

//         actions: [

//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),

//           ElevatedButton(
//             onPressed: () async {

//               final name = createDocumentNameController.text.trim();

//               if (name.isEmpty) return;

//               final workspaceId = context.read<ActiveWorkspaceProvider>().activeWorkspace!.id;

//               final success = await context.read<WorkspaceDocumentProvider>().createDocument(workspaceId, name);

//               if (success) {
//                 createDocumentNameController.clear();
//                 codeController.clear();
//                 // ignore: use_build_context_synchronously
//                 Navigator.pop(context);
//               }

//             },
//             child: const Text("Create"),
//           ),

//         ],
//       );

//     },
//   );
// }


}