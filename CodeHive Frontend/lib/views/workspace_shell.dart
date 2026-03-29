import 'dart:async';
import 'package:collab_code_editor/App_Theme/app_colors.dart';
import 'package:collab_code_editor/utils/snackbar_builder.dart';
import 'package:collab_code_editor/utils/text_form_field.dart';
import 'package:collab_code_editor/execution/execution_provider.dart';
import 'package:collab_code_editor/presence/presenceprovider.dart';
import 'package:collab_code_editor/services/socket_services.dart';
import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/workspace/activeworkspaceprovider.dart';
import 'package:collab_code_editor/workspace_document/workspacedocumentprovider.dart';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter/services.dart';

class Workspaceshell extends StatefulWidget {
  const Workspaceshell({super.key});

  @override
  State<Workspaceshell> createState() => _WorkspaceshellState();
}

class _WorkspaceshellState extends State<Workspaceshell> {

  FocusNode editorFocusNode = FocusNode();

  String? currentDocumentid;

  late CodeController codeController;

  TextEditingController inputController = TextEditingController();
  TextEditingController createDocumentNameController = TextEditingController();

  late SocketService socketService;

  bool isDrawerOpen = true;

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

      editorFocusNode.requestFocus();

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

    // if(activeDocumentProvider.activeDocument != null && currentDocumentid != activeDocumentProvider.activeDocument!.id && mounted){
    if(activeDocumentProvider.activeDocument != null && currentDocumentid != activeDocumentProvider.activeDocument!.id){
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
          leading: MediaQuery.of(context).size.width < 800
          ? IconButton(
            tooltip: isDrawerOpen? 'Close Sidebar' : 'Open Sidebar',
              icon: Icon(Icons.menu),
              onPressed: () {
                setState(() => isDrawerOpen = true);
              },
            )
          : null,
        centerTitle: false,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: AppColors.border,
            ),
            borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(12))
          ),
          backgroundColor: AppColors.surface,
          title: Text(
            activeWorkspaceProvider.activeWorkspace!.name,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [

            IconButton(
              tooltip: "Save",
              onPressed: () {
                if(activeDocumentProvider.activeDocument != null){
                  activeDocumentProvider.saveDocumentContent(
                      activeDocumentProvider.activeDocument!.id,
                      codeController.text
                  );
                }
              },
              icon: const Icon(Icons.save,),
            ),

            IconButton(
              tooltip: "Run",
              onPressed: () {
                if(activeDocumentProvider.activeDocument != null){

                  final code = codeController.text;
                  final input = inputController.text;

                  context.read<ExecutionProvider>().runCode(code, input);
                }
              },
              icon: const Icon(Icons.play_arrow,),
            ),
            IconButton(
              tooltip: "Create File",
              onPressed: () {
                showCreateDocumentDialog();
              },
              icon: const Icon(Icons.add_box_outlined),
            ),
            IconButton(
              tooltip: "Share",
              onPressed: () {
                shareWorkspace();
              },
              icon: const Icon(Icons.share),
            ),

            IconButton(
              tooltip: "Close",
              onPressed: () {
                activeWorkspaceProvider.clearActiveWorkspace();
                activeDocumentProvider.cleanWorkspaceDocument();
                context.read<ExecutionProvider>().clearExecution();
                socketService.disconnect();
              },
              icon: const Icon(Icons.close),
            ),

          ],
        ),

        body: LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Stack(
          children: [

            /// 🔹 MAIN LAYOUT (YOUR ORIGINAL CODE, JUST SLIGHTLY WRAPPED)
            Positioned.fill(
              child: Row(
                children: [

                  /// 🔥 SIDEBAR (ONLY DESKTOP)
                  if (!isMobile)
                    Container(
                      width: 220,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

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
                                    children: [
                                      Icon(sidebarOptions[index]["Icon"],
                                          color: AppColors.primaryVariant),
                                      SizedBox(width: 5),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          sidebarOptions[index]["Name"],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          Expanded(
                            flex: 8,
                            child: sidebarOptionsSelectedIndex == 0
                                ? Consumer<PresenceProvider>(
                                    builder: (context, presence, child) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text("Members :" , style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            color: AppColors.textPrimary, fontSize: 16 
                                            ),),
                                          ...presence.activeUsers.map(
                                            (user) => Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text("• $user",
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Colors.white, fontSize: 16 
                                              )
                                            ),
                                          )
                                      ),
                                      ],
                                      );
                                    },
                                  )
                                : Consumer<WorkspaceDocumentProvider>(
                                    builder: (context, document, child) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            "Documents :",
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 16,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: document.documents.length,
                                              itemBuilder: (context, index) {
                                                final doc = document.documents[index];
                                                final isSelected =
                                                    document.activeDocument?.id == doc.id;

                                                return _DocumentTile(
                                                  name: doc.name,
                                                  isSelected: isSelected,
                                                  onTap: () => switchDocument(index),
                                                  onDelete: () =>
                                                      showDeleteDocumentDialogue(index),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),

                  /// 🔹 MAIN AREA (UNCHANGED)
                  Expanded(
                    child: Column(
                      children: [

                        /// EDITOR
                        Expanded(
                          flex: 7,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border, width: 1.2),
                            ),
                            child: activeDocumentProvider.activeDocument == null
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Create a file and start coding',
                                    ),
                                  )
                                : _buildEditor(activeDocumentProvider),
                          ),
                        ),

                        /// INPUT + OUTPUT
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
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
                                          color: AppColors.surface,
                                          border: Border.all(color: AppColors.border, width: 1.2),
                                        ),
                                        child: Consumer<ExecutionProvider>(
                                          builder: (context, execProvider, _) {

                                            if (execProvider.isExecuting) {
                                              return Center(child: CircularProgressIndicator());
                                            }

                                            if (execProvider.error.isNotEmpty) {
                                              return SingleChildScrollView(
                                                child: SelectableText(
                                                  'Error :\n${execProvider.error}',
                                                  style: Theme.of(context).textTheme.bodyMedium!
                                                      .copyWith(color: Colors.red, fontSize: 16),
                                                ),
                                              );
                                            }

                                            if (execProvider.output.isNotEmpty) {
                                              return SingleChildScrollView(
                                                child: SelectableText(
                                                  'Output :\n${execProvider.output}',
                                                  style: Theme.of(context).textTheme.bodyMedium!
                                                      .copyWith(color: AppColors.textSecondary, fontSize: 16),
                                                ),
                                              );
                                            }

                                            return SelectableText(
                                              "Outputs Will Appear Here",
                                              style: Theme.of(context).textTheme.bodyMedium!
                                                  .copyWith(fontSize: 16),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    /// INPUT
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.border, width: 1.2),
                                        ),
                                        child: TextField(
                                          style: TextFormFieldBuilder().fieldTextStyle,
                                          textAlignVertical: TextAlignVertical.top,
                                          controller: inputController,
                                          maxLines: null,
                                          expands: true,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.zero,
                                              borderSide: BorderSide(color: AppColors.border, width: 0.01),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.zero,
                                              borderSide: BorderSide(color: AppColors.border, width: 0.01),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.zero,
                                              borderSide: BorderSide(color: AppColors.border, width: 0.01),
                                            ),
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
                ],
              ),
            ),

            /// 🔥 OVERLAY
            if (isMobile && isDrawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => isDrawerOpen = false),
                  child: Container(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),

            /// 🔥 FLOATING DRAWER (ONLY MOBILE)
            if (isMobile)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                left: isDrawerOpen ? 0 : -240,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔥 SAME SIDEBAR CONTENT (COPY PASTED, NO CHANGE)
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
                                children: [
                                  Icon(sidebarOptions[index]["Icon"],
                                      color: AppColors.primaryVariant),
                                  SizedBox(width: 5),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      sidebarOptions[index]["Name"],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      Expanded(
                        flex: 8,
                        child: sidebarOptionsSelectedIndex == 0
                            ? Consumer<PresenceProvider>(
                                builder: (context, presence, child) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text("Members :" , style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            color: AppColors.textPrimary, fontSize: 16 
                                            ),),
                                      ...presence.activeUsers.map(
                                        (user) => Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text("• $user",
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Colors.white, fontSize: 16 
                                              )
                                        ),
                                      )
                                  )],
                                  );
                                },
                              )
                            : Consumer<WorkspaceDocumentProvider>(
                                builder: (context, document, child) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text( 
                                            "Documents :",
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 16,
                                                ),
                                          ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: document.documents.length,
                                          itemBuilder: (context, index) {
                                            final doc = document.documents[index];
                                            final isSelected =
                                                document.activeDocument?.id == doc.id;

                                            return _DocumentTile(
                                              name: doc.name,
                                              isSelected: isSelected,
                                              onTap: () {
                                                switchDocument(index);
                                                setState(() => isDrawerOpen = false);
                                              },
                                              onDelete: () =>
                                                  showDeleteDocumentDialogue(index),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

            
          ],
        );
      },
    ),
      ),
    );
  }





/// METHODS
/// EDITOR WIDGET
Widget _buildEditor(WorkspaceDocumentProvider provider) {

   return Theme(
    data: Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        // contentPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.all(12),
        filled: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    ),
   child: CodeTheme(
            data: CodeThemeData(styles: monokaiSublimeTheme),
            child: CodeField(
              
            // padding: EdgeInsets.all(8), // this did not work
            controller: codeController,
            focusNode: editorFocusNode,
            expands: true,
            maxLines: null,
            // padding: EdgeInsets.all(12),
          cursorColor: AppColors.primary,
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: Colors.white,
          ),
        
     
        lineNumberStyle: const LineNumberStyle(
          textAlign: TextAlign.left,
          background: AppColors.surface,
          width: 70,
          textStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          margin: 0
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
    //  ),
   ));
}








/// SHOW DEBUG CONSOLE
void showCreateDocumentDialog() {

  showDialog(
    context: context,
    builder: (context) {

      return AlertDialog(
        title: Text("Create New File", 
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.textPrimary,
        )),

        content: TextField(
          style: TextFormFieldBuilder().fieldTextStyle,
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
        title:  Text("Are You Sure You Want To Delete This Document", style: Theme.of(context).textTheme.bodyMedium),

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
    return LayoutBuilder(
      builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 450;
      return AlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(right: 38),
          child: Text('Workspace ID :', 
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textPrimary,
          ),
          ),
        ),
        content: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
            color: AppColors.surface
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(roomID, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textPrimary),maxLines: 2,),
              ),
              if(!isMobile)
              IconButton(onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: roomID)
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackbarBuilder().snackbarBuilder(content: 'Copied to Clipboard')
                );
              }, icon: Icon(Icons.copy, color: AppColors.textPrimary,))
            ],
          ),
        ),
        actions: [
          if(!isMobile)
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text('Close')),
          if(isMobile)
          ...[
            TextButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text('Close')),
          ElevatedButton(onPressed: () {
            Clipboard.setData(
                  ClipboardData(text: roomID)
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackbarBuilder().snackbarBuilder(content: 'Copied to Clipboard')
                );
          }, child: Text('Copy'))]
      
        ],
      );
  });
  });
 }

} // End of Stateful Widget






// DOCUMENT TILE EFFECT
class _DocumentTile extends StatefulWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DocumentTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_DocumentTile> createState() => _DocumentTileState();
}

class _DocumentTileState extends State<_DocumentTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),

      child: GestureDetector(
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,

          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),

          transform: isHovered
              // ignore: deprecated_member_use
              ? (Matrix4.identity()..scale(1.02))
              : Matrix4.identity(),

          decoration: BoxDecoration(
            color: widget.isSelected
                // ignore: deprecated_member_use
                ? AppColors.primary.withOpacity(0.15) // 🔥 selected
                : isHovered
                    // ignore: deprecated_member_use
                    ? AppColors.surface.withOpacity(0.6)
                    : Colors.transparent,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : isHovered
                      ? AppColors.primaryVariant
                      : AppColors.border,
            ),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// LEFT SIDE
              Row(
                children: [
                  Icon(
                    Icons.file_copy,
                    size: 20,
                    color: widget.isSelected
                        ? AppColors.primary
                        : isHovered
                            ? AppColors.primaryVariant
                            : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),

                  Text(
                    widget.name,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                  ),
                ],
              ),

              /// DELETE BUTTON
              IconButton(
                onPressed: widget.onDelete,
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[900],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}