import 'package:collab_code_editor/App_Theme/app_colors.dart';
import 'package:collab_code_editor/services/authprovider.dart';
import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/utils/text_form_field.dart';
// import 'package:collab_code_editor/services/authprovider.dart';
// import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/workspace/activeworkspaceprovider.dart';
import 'package:collab_code_editor/workspace/workspaceprovider.dart';
import 'package:flutter/material.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  bool isSideBarOpen = true;
  
  TextEditingController joinRoomController = TextEditingController();
  TextEditingController workspaceNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
    
      body: LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [

            /// 🔹 MAIN CONTENT (always visible)
            Positioned.fill(
              child: Column(
                children: [

                  /// 🔥 MENU BUTTON
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      hoverColor: Colors.transparent,
                      tooltip: 'Open Sidebar',
                      icon: Image.asset(
                        'assets/images/codehive_logo.png',
                          // height: 46,
                          // width: 46,

                          scale: 15.5,
                      ),
                      onPressed: () {
                        setState(() => isSideBarOpen = true);
                      },
                    ),
                  ),

                  /// 🔥 YOUR ORIGINAL CONTENT (UNCHANGED)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Join a room and start coding',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              /// CREATE BUTTON (UNCHANGED)
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Create Workspace",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: AppColors.textPrimary),
                                        ),
                                        content: TextFormField(
                                          style: TextFormFieldBuilder().fieldTextStyle,
                                          controller: workspaceNameController,
                                          decoration: InputDecoration(
                                            hintText: "Workspace name",
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              workspaceNameController.clear();
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final workspaceprovider =
                                                  context.read<Workspaceprovider>();
                                              final navigator = Navigator.of(context);

                                              final success =
                                                  await workspaceprovider.createWorkspace(
                                                      workspaceNameController.text);

                                              if (success) {
                                                navigator.pop();
                                              }
                                            },
                                            child: Text("Create"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text('Create Room'),
                              ),

                              SizedBox(width: 10),

                              /// JOIN BUTTON (UNCHANGED)
                              TextButton(
                                onPressed: () {
                                  joinRoom();
                                },
                                child: Text('Join Room'),
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


            /// 🔹 OVERLAY (click outside to close)
            if (isSideBarOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() => isSideBarOpen = false);
                  },
                  child: Container(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),

    /// 🔹 FLOATING DRAWER
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              left: isSideBarOpen ? 0 : -260,
              top: 0,
              bottom: 0,
              child: Container(
                width: 250,
                color: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// HEADER
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Workspaces",
                              style: Theme.of(context).textTheme.bodyLarge),

                          Row(
                            children: [
                              IconButton(
                              tooltip: 'Logout',
                              icon: Icon(Icons.logout_rounded),
                              onPressed: () {
                                context.read<AuthProvider>().logout();
                                context.read<Workspaceprovider>().cleanWorkspace();
                                context.read<Userprovider>().cleanUser();
                                context.read<ActiveWorkspaceProvider>().clearActiveWorkspace();
                              
                                /// optional: close drawer
                                setState(() => isSideBarOpen = false);
                              },
                              ),

                              IconButton(
                            icon: Icon(Icons.close),
                            tooltip: 'Close Sidebar',
                            onPressed: () {
                              setState(() => isSideBarOpen = false);
                            },
                          ),
                            ],
                          ),

                          
                        ],
                      ),
                    ),

                    /// LIST
                    Expanded(
                      child: Consumer<Workspaceprovider>(
                        builder: (context, workspaceprovider, _) {
                          return ListView.separated(
                            itemBuilder: (context, index) {
                              final workspace =
                                  workspaceprovider.currentWorkspaces[index];

                              return _WorkspaceHoverTile(
                                name: workspace.name,
                                onTap: () {
                                  context
                                      .read<ActiveWorkspaceProvider>()
                                      .setActiveWorkspace(workspace);

                                  /// 🔥 auto close
                                  setState(() => isSideBarOpen = false);
                                },
                              );
                            },
                            itemCount:
                                workspaceprovider.currentWorkspaces.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 4),
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
    );
  }


  ///  JOIN ROOM FUNCTION
  void joinRoom(){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Enter Workspace ID :', 
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.textPrimary
        ),
        ),
        content: TextField(
          style: TextFormFieldBuilder().fieldTextStyle,
          controller: joinRoomController,
           decoration:  InputDecoration(
            border: Theme.of(context).inputDecorationTheme.border,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            hintText: "example@id",
          ),
        ),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text('Cancel')),
          ElevatedButton(onPressed: () async{
            final workspaceprovider = context.read<ActiveWorkspaceProvider>();
            final success = await workspaceprovider.joinRoom(joinRoomController.text);
            if(success){
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              joinRoomController.clear();
            }else{
              joinRoomController.clear();
            }

          }, child: Text('Join'))
        ],
      );
    });
  }

}




// HOVERING EFFECT
class _WorkspaceHoverTile extends StatefulWidget {
  final String name;
  final VoidCallback onTap;

  const _WorkspaceHoverTile({
    required this.name,
    required this.onTap,
  });

  @override
  State<_WorkspaceHoverTile> createState() => _WorkspaceHoverTileState();
}

class _WorkspaceHoverTileState extends State<_WorkspaceHoverTile> {
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

          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),

          transform: isHovered
              // ignore: deprecated_member_use
              ? (Matrix4.identity()..scale(1.03)) // 🔥 size increase
              : Matrix4.identity(),

          decoration: BoxDecoration(
            color: isHovered
                // ignore: deprecated_member_use
                ? AppColors.surface.withOpacity(0.6)
                : Colors.transparent,

            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: isHovered
                  ? AppColors.primary
                  : const Color.fromARGB(255, 47, 53, 62),
            ),

            boxShadow: isHovered
                ? [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),

          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),

            leading: Icon(
              Icons.folder,
              color: isHovered
                  ? AppColors.primary // 🔥 changes on hover
                  : AppColors.primaryVariant,
            ),

            title: Text(
              widget.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}