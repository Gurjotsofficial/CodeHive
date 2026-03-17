import 'dart:async';
import 'package:collab_code_editor/execution/execution_provider.dart';
import 'package:collab_code_editor/presence/presenceprovider.dart';
import 'package:collab_code_editor/services/socket_services.dart';
import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/workspace/activeworkspaceprovider.dart';
import 'package:collab_code_editor/workspace_document/workspacedocumentprovider.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
// import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:provider/provider.dart';
import 'package:highlight/languages/javascript.dart';
// import 'package:flutter_highlight/themes/monokai-sublime.dart' as monokai;

class TestWorkspaceshell extends StatefulWidget {
  const TestWorkspaceshell({super.key});

  @override
  State<TestWorkspaceshell> createState() => _TestWorkspaceshellState();
}

class _TestWorkspaceshellState extends State<TestWorkspaceshell> {

  late CodeController codeController;

  TextEditingController inputController = TextEditingController();
  TextEditingController createDocumentNameController = TextEditingController();

  late SocketService socketService;

  Timer? _debounce;


  @override
  void initState() {
    super.initState();

     // initialising the code controller
      codeController = CodeController(
        text: "",
        language: javascript,
      );

     

    socketService = SocketService();
    socketService.connect();

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      final workspaceProvider = context.read<ActiveWorkspaceProvider>();
      final documentProvider = context.read<WorkspaceDocumentProvider>();
      final presenceProvider = context.read<PresenceProvider>();
      final userProvider = context.read<Userprovider>();

      final workspaceId = workspaceProvider.activeWorkspace!.id;

      /// Fetch documents
      await documentProvider.fetchDocuments(workspaceId);
      final activeDoc = documentProvider.activeDocument;

      // initialising the editor areas content according to the active document
      if (activeDoc != null) {
        codeController.text = activeDoc.content;
      }

      // Joining a room for the active document
      if (activeDoc != null) {
        final username = userProvider.currentUser!.name;
        socketService.joinDocument(
        activeDoc.id,
        username,
      );
    }

      /// Listen for remote code updates
   socketService.listenCodeChange((content) {

  if (content == codeController.text) return;

  Future.microtask(() {

    if (!mounted) return;

    codeController.value = TextEditingValue(
      text: content,
      selection: TextSelection.collapsed(offset: content.length),
    );

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
              onPressed: () {},
              icon: const Icon(Icons.swap_vert_circle_outlined,
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

                  const Text(
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
                                (user) => Text(
                                "• $user",
                                style: const TextStyle(fontSize: 16),
                              ),
                          )

                        ],
                      );
                    },
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


}