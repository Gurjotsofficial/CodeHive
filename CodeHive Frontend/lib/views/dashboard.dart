import 'package:collab_code_editor/services/authprovider.dart';
import 'package:collab_code_editor/user/userprovider.dart';
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
  
  TextEditingController joinRoomController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    TextEditingController workspaceNameController = TextEditingController();


    final activeworkspaceprovider = context.watch<ActiveWorkspaceProvider>();
    final workspaceprovider = context.watch<Workspaceprovider>();
    final userprovider = context.watch<Userprovider>();

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar:  AppBar(
      //     backgroundColor: const Color.fromARGB(255, 251, 161, 161),
      //     title: Text("Collaborative Code Editor", style: TextStyle(
      //       fontSize: 32,
      //       color: Colors.black
      //     ),
      //     ),
      //     centerTitle: true,
      //   ),
    
      body: Row(
        children: [
           Container(
            color: Colors.red[100],
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("WorkSpaces", style: TextStyle(fontSize: 20, color: Colors.black,)
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(itemBuilder: (context, index){
                        return GestureDetector(
                          onTap: () => {
                            debugPrint("Index of Workspace : $index"),
                            activeworkspaceprovider.setActiveWorkspace(workspaceprovider.currentWorkspaces[index]),
                            
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(14)),
                                
                              leading: Icon(Icons.sticky_note_2_outlined),
                                
                              title: Text(workspaceprovider.currentWorkspaces[index].name, 
                              style: TextStyle(color: Colors.black, fontSize: 12),
                              ),

                            ),
                          ),
                        );
                      },
                      itemCount: workspaceprovider.currentWorkspaces.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                        child: Divider(height: 5,thickness: 1,color: Colors.black,),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome to Collabrative Code Editor',
                style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500
                        ), 
                ),
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                            title: Text("Create Workspace"),

                            content: TextFormField(
                              controller: workspaceNameController,
                              decoration: InputDecoration(
                                hintText: "Workspace name",
                              ),
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  workspaceNameController.clear();
                                  Navigator.pop(context); // closes dialog
                                },
                                child: Text("Cancel"),
                              ),

                              ElevatedButton(
                                onPressed: () async{
                                  // your logic here
                                  final workspaceprovider = context.read<Workspaceprovider>();
                                  final navigator = Navigator.of(context);
                                    final success =
                                        await workspaceprovider.createWorkspace(workspaceNameController.text);  
                                       debugPrint("Create workspace success: $success");

                                    if (success) {
                                      navigator.pop();
                                }
                                },
                                child: Text("Create"),
                              ),
                            ],
                          );
                          }
                          );
                        },
                         child: Text('Create Room', 
                         style: TextStyle(
                                            fontSize: 14,
                                          ),
                                          ),
                          ),
                          SizedBox( width: 10,),
                      TextButton(
                        onPressed: () async{
                          joinRoom();
                        },
                         child: Text('Join Room', 
                         style: TextStyle(
                                            fontSize: 14
                                          ),
                                          ),
                          ),
                          SizedBox( width: 10,),
                      TextButton(
                        onPressed: (
                        ) {
                         context.read<AuthProvider>().logout();
                         workspaceprovider.cleanWorkspace();
                         userprovider.cleanUser();
                         activeworkspaceprovider.clearActiveWorkspace();
                        },
                         child: Text('Logout', 
                         style: TextStyle(
                                            fontSize: 14
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
    );
  }


  ///  JOIN ROOM FUNCTION
  void joinRoom(){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Enter Workspace ID :', style: TextStyle(fontSize: 20),),
        content: TextField(
          controller: joinRoomController,
           decoration:  InputDecoration(
            border: joinRoomBorder,
            focusedBorder: joinRoomBorder,
            // enabledBorder: joinRoomBorder,
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

  final joinRoomBorder = OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black)
            );
}