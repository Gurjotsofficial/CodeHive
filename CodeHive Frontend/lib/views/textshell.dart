import 'dart:async';
import 'package:collab_code_editor/execution/execution_provider.dart';
import 'package:collab_code_editor/presence/presenceprovider.dart';
import 'package:collab_code_editor/services/socket_services.dart';
import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/workspace/activeworkspaceprovider.dart';
import 'package:collab_code_editor/workspace_document/workspacedocumentprovider.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:provider/provider.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter/services.dart';

class TestWorkspaceshell extends StatefulWidget {
  const TestWorkspaceshell({super.key});

  @override
  State<TestWorkspaceshell> createState() => _TestWorkspaceshellState();
}

class _TestWorkspaceshellState extends State<TestWorkspaceshell> {

  String? currentDocumentid;

  late CodeController codeController;

  TextEditingController inputController = TextEditingController();
  TextEditingController createDocumentNameController = TextEditingController();

  late SocketService socketService;

  Timer? _debounce;

  // Making Sidebar More Interactive
  // Initializing a List of options in the sidebar
  List<Map> sidebarOptions = [
    {"Name": "Members", "Icon" : Icons.person},
    {"Name" : "Documents" ,"Icon" : Icons.folder}
  ];
  // Creating a variable to Track the list
  late int sidebarOptionsSelectedIndex;
  late int sidebarOptionsSelectedPreviousIndex;


  @override
  void initState() {
    super.initState();

     // initialising the code controller
      codeController = CodeController(
        text: "",
        language: javascript,
      );

      sidebarOptionsSelectedIndex = 0;
      sidebarOptionsSelectedPreviousIndex = 0;
     

    socketService = SocketService();
    socketService.connect();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      final workspaceProvider = context.read<ActiveWorkspaceProvider>();
      final documentProvider = context.read<WorkspaceDocumentProvider>();
      final presenceProvider = context.read<PresenceProvider>();
      // final userProvider = context.read<Userprovider>();

      final workspaceId = workspaceProvider.activeWorkspace!.id;

      /// Fetch documents
      await documentProvider.fetchDocuments(workspaceId);
      // final activeDoc = documentProvider.activeDocument;

      // initialising the editor areas content according to the active document
    //   if (activeDoc != null) {
    //     codeController.text = activeDoc.content;
    //   }

    //   // Joining a room for the active document
    //   if (activeDoc != null) {
    //     final username = userProvider.currentUser!.name;
    //     socketService.joinDocument(
    //     activeDoc.id,
    //     username,
    //   );
    // }

      /// Listen for remote code updates
   socketService.listenCodeChange((content) {

  if (content == codeController.text) return;

  Future.microtask(() {

    if (!mounted) return;

    codeController.value = TextEditingValue(
      text: content,
      selection: TextSelection.collapsed(offset: content.length),
    );
    // codeController.text = content;

    documentProvider.updateLocalContent(content);

  });

});




      /// Listen for presence updates
      socketService.listenPresence((users) {
        presenceProvider.updatePresence(users);
      });

    });

  }

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
    // final workspaceDocProvider = context.read<WorkspaceDocumentProvider>();
    final userProvider = context.read<Userprovider>();

    if(activeDocumentProvider.activeDocument != null && currentDocumentid != activeDocumentProvider.activeDocument!.id && mounted){
    WidgetsBinding.instance.addPostFrameCallback((_) {
    final activeDoc = activeDocumentProvider.activeDocument;
        if(activeDoc != null){
          if(currentDocumentid != activeDoc.id){
            debugPrint('Calling Set Active Workspace Function');
            setActiveWorkspace(activeDocumentProvider, userProvider);
          }
        }
    });
    }
    

    if(activeDocumentProvider.isLoading == true){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        )
      );
    }

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
                  activeDocumentProvider.saveDocumentContent(
                      activeDocumentProvider.activeDocument!.id,
                      codeController.text
                  );
                }
              },
              icon: const Icon(Icons.save, color: Colors.black),
            ),

            IconButton(
              onPressed: () {
                if(activeDocumentProvider.activeDocument != null){

                  final code = codeController.text;
                  final input = inputController.text;

                  context.read<ExecutionProvider>().runCode(code, input);
                }
              },
              icon: const Icon(Icons.play_arrow, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                showCreateDocumentDialog();
              },
              icon: const Icon(Icons.add_box_outlined,
                  color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                shareWorkspace();
              },
              icon: const Icon(Icons.share,
                  color: Colors.black),
            ),

            IconButton(
              onPressed: () {
                activeWorkspaceProvider.clearActiveWorkspace();
                activeDocumentProvider.cleanWorkspaceDocument();
                context.read<ExecutionProvider>().clearExecution();
                socketService.disconnect();
              },
              icon: const Icon(Icons.close, color: Colors.black),
            ),

          ],
        ),

        body: Row(
          children: [

            /// LEFT SIDEBAR
            Container(
              width: 220,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // const Text(
                  //   "Members",
                  //   style: TextStyle(fontSize: 18),
                  // ),
                  Expanded(
                    child: ListView.builder(
                              itemCount: sidebarOptions.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    sidebarOptionsSelectedIndex = index;
                                    setState(() {});
                                  },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(sidebarOptions[index]["Name"], style: TextStyle(fontSize: 18),)
                                    ),
                                        SizedBox(width: 5,),
                                        Icon(sidebarOptions[index]["Icon"]),
                                      ],
                                  ),
                                );
                              }
                              ),
                  ),

                  Expanded(
                    flex: 8,
                    child: sidebarOptionsSelectedIndex == 0 ? Consumer<PresenceProvider>(
                      builder: (context, presence, child) {
                    
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            const SizedBox(height: 8),
                            Text("Members :" , style: TextStyle(fontSize: 18),),
                            ...presence.activeUsers.map(
                                  (user) => Text(
                                  "• $user",
                                  style: const TextStyle(fontSize: 16),
                                ),
                            )
                    
                          ],
                        );
                      },
                    ) : Consumer<WorkspaceDocumentProvider>(
                      builder: (context, document, child) {
                    
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            const SizedBox(height: 8),
                            Text("Documents :", style: TextStyle(fontSize: 18),),
                            ...document.documents.asMap().entries.map((entry) {
                                    final document = entry.value;
                                    final index = entry.key;

                                    return GestureDetector(
                                    onTap: () {
                                      switchDocument(index);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(colors: [const Color.fromARGB(255, 199, 180, 180), const Color.fromARGB(255, 150, 148, 150)] , tileMode: TileMode.clamp)
                                      ),
                                      // color: Colors.purple[200],
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      // padding: EdgeInsets.all(2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                          // "• ${document.name}",
                                          "  ${document.name}",
                                          style: const TextStyle(fontSize: 16),
                                              ),
                                      
                                          IconButton(onPressed: () async{
                                            debugPrint(index.toString());
                                            showDeleteDocumentDialogue(index);
                                            setState(() {});
                                          }, icon: Icon(Icons.delete, color: Colors.red[900],size: 22,))
                                        ],
                                      ),
                                    ),
                                  );}
                            )
                    
                          ],
                        );
                      },
                    ) ,
                  )

                ],
              ),
            ),

            /// MAIN AREA
            Expanded(
              child: Column(
                children: [

                  /// EDITOR
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
                          ? const Text(
                        'No Document Exists in this Workspace',
                        style: TextStyle(fontFamily: 'monospace'),
                      )
                          : _buildEditor(activeDocumentProvider),
                    ),
                  ),

                  /// INPUT + OUTPUT
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [

                        /// OUTPUT
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

                        /// INPUT
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black, width: 1.2),
                            ),

                            child: TextField(
                              controller: inputController,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                helperStyle:
                                TextStyle(fontFamily: 'monospace'),
                                hintText: "Kindly Pass Your Input Here!",
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

/// METHODS
/// EDITOR WIDGET
Widget _buildEditor(WorkspaceDocumentProvider provider) {

   return CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme),
     child: CodeField(
      controller: codeController,
      expands: true,
      padding: const EdgeInsets.all(12),
     
      textStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        color: Colors.white,
      ),
      lineNumberStyle: const LineNumberStyle(
        width: 50,
        textStyle: TextStyle(
          color: Colors.grey,
          fontSize: 13,
        ),
      ),
      onChanged: (value) {
     
        provider.updateLocalContent(value);
     
        if (_debounce?.isActive ?? false) {
          _debounce!.cancel();
        }
     
        _debounce = Timer(const Duration(milliseconds: 200), () {
     
          final doc = provider.activeDocument;
          if (doc == null) return;
     
          socketService.emitCodeChange(doc.id, value);
     
          debugPrint("Change Emitted");
     
        });
     
      },
       ),
   );
}








/// SHOW DEBUG CONSOLE
void showCreateDocumentDialog() {

  showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(
        title: const Text("Create New File"),

        content: TextField(
          controller: createDocumentNameController,
          decoration: const InputDecoration(
            hintText: "Enter file name",
          ),
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              final name = createDocumentNameController.text.trim();

              if (name.isEmpty) return;

              final workspaceId = context.read<ActiveWorkspaceProvider>().activeWorkspace!.id;
              final workspaceDocumentProvider = context.read<WorkspaceDocumentProvider>();
              final success = await workspaceDocumentProvider.createDocument(workspaceId, name);

              if (success) {
                createDocumentNameController.clear();
                sidebarOptionsSelectedPreviousIndex = workspaceDocumentProvider.documents.length - 1;
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }

            },
            child: const Text("Create"),
          ),

        ],
      );

    },
  );
}

void showDeleteDocumentDialogue(int index) async{
  showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(
        title: const Text("Are You Sure You Want To Delete This Document"),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              final workspaceDocumentProvider = context.read<WorkspaceDocumentProvider>();

              final success = await workspaceDocumentProvider.deleteWorkspaceDocument(index);

              if (success) {
                if(sidebarOptionsSelectedPreviousIndex == index){
                  final documents = workspaceDocumentProvider.documents;
                if (documents.isNotEmpty) {
                  if (index > 0) {
                    sidebarOptionsSelectedPreviousIndex = index - 1;
                  } else {
                    sidebarOptionsSelectedPreviousIndex = 0;
                  }
                }
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }

            },
            child: const Text("Delete"),
          ),

        ],
      );

    },
  );
}


/// SET ACTIVE WORKSPACE
void setActiveWorkspace(WorkspaceDocumentProvider provider, Userprovider userProvider){
  if(currentDocumentid != null){
    socketService.leaveDocument(currentDocumentid!);
    debugPrint('Left Previous Document');
  }
  if(provider.activeDocument != null){
  final username = userProvider.currentUser!.name;
  final activeDocId = provider.activeDocument!.id;
  socketService.joinDocument(activeDocId, username);

  debugPrint('Joined New Document');
  debugPrint('Previous Index : ${sidebarOptionsSelectedPreviousIndex.toString()}');

  currentDocumentid = activeDocId;
  final content = provider.activeDocument!.content;

  codeController.value = TextEditingValue(
  text: content,
  selection: TextSelection.collapsed(offset: content.length),
);

  debugPrint('Reset currentDocumentid and codeController.text');
  debugPrint('New Document id : ${provider.activeDocument!.id} and name : ${provider.activeDocument!.name}');
  debugPrint('content : ${provider.activeDocument!.content}');
  }else{
    codeController.clear();
  }
}
 

 /// SWITCH WORKSPACE DOCUMENT FUNCTION
 void switchDocument(int index){
  final workspaceDocProvider = context.read<WorkspaceDocumentProvider>();

  if(sidebarOptionsSelectedPreviousIndex >= 0 && sidebarOptionsSelectedPreviousIndex < workspaceDocProvider.documents.length)
  {
  if(workspaceDocProvider.documents[sidebarOptionsSelectedPreviousIndex].content != codeController.text){
  workspaceDocProvider.documents[sidebarOptionsSelectedPreviousIndex].content = codeController.text;
  debugPrint('Temporarily Updated Local Content');
  }
  }
  workspaceDocProvider.swtichWorkspaceDocument(index);
  sidebarOptionsSelectedPreviousIndex = index;
 }


 /// SHARE WORKSPACE
 void shareWorkspace(){
  final activeWorkspaceProvider = context.read<ActiveWorkspaceProvider>();
  final roomID = activeWorkspaceProvider.activeWorkspace!.id;
  showDialog(context: context, builder: (context) {
    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(right: 38),
        child: Text('Workspace ID :', style: TextStyle(fontSize: 20),),
      ),
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white54
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(roomID),
            IconButton(onPressed: () {
              Clipboard.setData(
                ClipboardData(text: roomID)
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied to Clipboard', style: TextStyle(color: Colors.white),),
                duration: Duration(seconds: 1),backgroundColor: Colors.red[200],)
              );
            }, icon: Icon(Icons.copy))
          ],
        ),
      ),
      actions: [
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text('Close'))
      ],
    );
  });
 }
}