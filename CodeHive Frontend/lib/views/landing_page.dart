import 'package:collab_code_editor/App_Theme/app_colors.dart';
import 'package:collab_code_editor/utils/snackbar_builder.dart';
import 'package:collab_code_editor/utils/text_form_field.dart';
import 'package:collab_code_editor/services/authprovider.dart';
import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/views/dashboard.dart';
// import 'package:collab_code_editor/views/test_shell_2.dart';
import 'package:collab_code_editor/views/workspace_shell.dart';
// import 'package:collab_code_editor/views/workspaceshell.dart';
import 'package:collab_code_editor/workspace/activeworkspaceprovider.dart';
import 'package:collab_code_editor/workspace/workspaceprovider.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_highlight/themes/dark.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}


class _LandingPageState extends State<LandingPage> {

  
  TextEditingController authNameController = TextEditingController();
  TextEditingController authEmailController = TextEditingController();
  TextEditingController authPasswordController = TextEditingController();
  TextEditingController authConfirmPasswordController = TextEditingController();


  int authMode = 0;
  GlobalKey<FormState> authFormKey = GlobalKey();

  void switchToLogin(){
    setState(() {
      authMode = 0;
    });
  }
  void switchToSignUp(){
    setState(() {
      authMode = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      
    debugPrint('initState function called');
    // bringing in userprovider
    final userprovider = context.read<Userprovider>();
    final workspaceprovider = context.read<Workspaceprovider>();
    final authprovider = context.read<AuthProvider>();
      
    debugPrint('authprovider isLoggedIn function called');
      authprovider.isLoggedIn(userprovider, workspaceprovider);
    });
  }

  // Creating a provider
  @override
  Widget build(BuildContext context) {


    return Consumer<AuthProvider>(builder: (context, auth, child){
      if (auth.isAuthenticated == null) {

        return Scaffold(
          backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(),
      )
      );
      }
      else if(auth.isAuthenticated == true){ 
      return Consumer<ActiveWorkspaceProvider>(builder: (context, activeworkspace, child){
        if(activeworkspace.activeWorkspace == null){
          return const Dashboard();
        }
        else{
          return const Workspaceshell();
        }
      });
      }
    else {
      return SafeArea(
      child:  Scaffold(
        backgroundColor: AppColors.background,
        appBar:  AppBar(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: AppColors.border,
            ),
            borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(12))
          ),
          backgroundColor: AppColors.surface,
          title: Text("Collaborative Code Editor", style: Theme.of(context).textTheme.headlineLarge
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Collaborative code editing built for learning and teamwork.",
                style: Theme.of(context).textTheme.bodyLarge
                  ),
              ),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("A simple collaborative code editor \ndesigned for students and learners \nto practice coding together, \ndiscuss solutions, and build projects \nas a team.", 
                    style: Theme.of(context).textTheme.bodyMedium
                    ),

                      Form(
                        key: authFormKey,
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 30),
                          elevation: 8,
                          shadowColor: const Color.fromARGB(255, 0, 0, 0),
                          color:  AppColors.surface,
                          // color: const Color.fromARGB(255, 251, 161, 161),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: authMode == 0? 120: 50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // SizedBox(
                                  // // width: 320,
                                  // height: 75, 
                                  //     child: Row(
                                  //       mainAxisAlignment: MainAxisAlignment.center,
                                  //       children: [
                                  //         Text(
                                  //            authMode == 0? "Login": "Create Account",
                                  //            style: TextStyle(fontSize: 24, color: Colors.white54),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                              
                                  if(authMode == 1) ...[
                                 
                                  TextFormFieldBuilder().fieldBuilder(
                                    fieldController: authNameController, 
                                    hinttext: "Name", 
                                    fieldicon: Icons.person),
                                  ],
                              
                                  TextFormFieldBuilder().fieldBuilder(
                                    fieldController: authEmailController, 
                                    hinttext: "example@gmail.com", 
                                    fieldicon: Icons.email,),

                                                      
                                  TextFormFieldBuilder().fieldBuilder(
                                    fieldController: authPasswordController, 
                                    hinttext: "Password", 
                                    fieldicon: Icons.key,
                                  ),

                                                      
                                  if(authMode == 1) ...[
                                  TextFormFieldBuilder().fieldBuilder(
                                    fieldController: authConfirmPasswordController, 
                                    hinttext: "Confirm Password", 
                                    fieldicon: Icons.key,),
                                
                                  ],
                                                      
                                                      
                                  SizedBox(
                                    width: 320,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () async{
                                             if(authMode == 0){
                                          if(authEmailController.text.trim().isEmpty || authPasswordController.text.trim().isEmpty)
                                          {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackbarBuilder().snackbarBuilder(content: "Please fill both the details")
                                            );
                                          }else if(!authEmailController.text.contains('@') || !authEmailController.text.contains('.'))
                                          {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackbarBuilder().snackbarBuilder(content: "Please Enter a Valid email")
                                            );
                                          }else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackbarBuilder().snackbarBuilder(content: "Login in Process")
                                            );
                                                if(authFormKey.currentState!.validate()){
                                                  final success = await auth.login(
                                                  authEmailController.text,
                                                   authPasswordController.text);
                                                   authPasswordController.clear();
                                                if(!context.mounted) return;
                                                if(success){
                                                  final authprovider = context.read<AuthProvider>();
                                                  final userprovider = context.read<Userprovider>();
                                                  final workspaceprovider = context.read<Workspaceprovider>();

                                                  await authprovider.isLoggedIn(userprovider, workspaceprovider);

                                                  authEmailController.clear();
                                                }
                                                }
                                                
                                          }}else if(authMode == 1){
                                            switchToLogin();
                                          }
                                          },
                                         child: Text("Login",
                                        style: TextStyle(
                                          fontSize: 14
                                        ),
                                        ),
                                        ),
                                        SizedBox( width: 20,),
                                        ElevatedButton(
                                          onPressed: () async { 
                                           if(authMode == 0){
                                            switchToSignUp();
                                           }else if(authMode == 1){
                                            if( authNameController.text.trim().isEmpty || authEmailController.text.trim().isEmpty || authPasswordController.text.trim().isEmpty || authConfirmPasswordController.text.trim().isEmpty){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackbarBuilder().snackbarBuilder(content: "Please fill all the details!")
                                            );
                                          }else if(!authEmailController.text.contains('@') || !authEmailController.text.contains('.')){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackbarBuilder().snackbarBuilder(content: "Please Enter a Valid email!")
                                            );
                                          }else if(authPasswordController.text != authConfirmPasswordController.text){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackbarBuilder().snackbarBuilder(content: "Please Enter same password in both fields!")
                                            );
                                          }else{
                                             ScaffoldMessenger.of(context).showSnackBar(
                                              SnackbarBuilder().snackbarBuilder(content: "Account Successfully Created!")
                                            );
                                                //  Navigator.of(context).pushAndRemoveUntil(
                                                //   MaterialPageRoute(
                                                //     builder: (context) => Dashboard(),
                                                //   ),
                                                //     (routes) => false
                                                // );
                              
                                                if(authFormKey.currentState!.validate()){
                                                   final success = await auth.signUp(
                                                    authNameController.text,
                                                  authEmailController.text,
                                                   authPasswordController.text,
                                                   authConfirmPasswordController.text,
                                                   );
                                                   if (!context.mounted) return;

                                                   if(success){
                                                    final authprovider = context.read<AuthProvider>();
                                                    final userprovider = context.read<Userprovider>();
                                                    final workspaceprovider = context.read<Workspaceprovider>();

                                                    await authprovider.isLoggedIn(userprovider, workspaceprovider);
                                                    authEmailController.clear();
                                                    authNameController.clear();
                                                   }
                                                   authPasswordController.clear();
                                                   authConfirmPasswordController.clear(); 

                                                }
                                            }
                                           }
                                        ElevatedButtonThemeData();
                                          }, child: Text("Sign Up",
                                        // style: TextStyle(
                                        //   fontSize: 14
                                        // ),
                                        
                                        ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
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
      ),
    );
    }
    });
  }
}