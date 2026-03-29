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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_highlight/themes/dark.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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


  int authMode = 1;
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
      child:  Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                Color(0xFF0F172A), // slightly bluish dark
                AppColors.background,
              ],
            ),
          ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: LayoutBuilder(
             builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 750;

                return SizedBox(
                  height: constraints.maxHeight,
                  child: Column(

                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                        child: ConstrainedBox(
                        constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                              fontSize: isMobile? 28 : 42,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        children: [
                                          TextSpan(
                                            text: "Welcome to ",
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                        
                                          // Gradient CodeHive
                                          WidgetSpan(
                                            child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                                // Glow layer
                                                Text(
                                                  "CodeHive",
                                                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                                        fontSize: isMobile? 28 : 42,
                                                        fontWeight: FontWeight.w700,
                                                        // ignore: deprecated_member_use
                                                        color: AppColors.primary.withOpacity(0.3),
                                                      ),
                                                ),
                        
                                                // Gradient text
                                                ShaderMask(
                                                  shaderCallback: (bounds) => LinearGradient(
                                                    colors: [
                                                      Color(0xFF3B82F6),
                                                      Color(0xFF60A5FA),
                                                      Color(0xFF22D3EE),
                                                    ],
                                                  ).createShader(bounds),
                                                  child: Text(
                                                    "CodeHive",
                                                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                                          fontSize: isMobile? 28: 42,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(height: 12),
                                    Text(
                                      "Collaborative coding experience built for learning and teamwork.",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: isMobile? 14 : 18),
                                    ),
                                  ],
                                ),
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            Center(
                              child: Column(
                                children: [
                                  
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if(!isMobile)
                                      Text("A simple collaborative coding platform \ndesigned for students and learners \nto practice coding together, \ndiscuss solutions, and build projects \nas a team.", 
                                      style: Theme.of(context).textTheme.bodyMedium
                                      ),
                                    
                                        Form(
                                          key: authFormKey,
                                          child: AnimatedSize(
                                            duration: Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            child: Container(
                                            margin: const EdgeInsets.symmetric(vertical: 30),
                                            decoration: BoxDecoration(
                                              // ignore: deprecated_member_use
                                              color: AppColors.surface.withOpacity(0.4), // subtle glass effect
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  // ignore: deprecated_member_use
                                                  color: Colors.black.withOpacity(0.25),
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 15),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isMobile? 15:40,
                                                vertical: 20
                                                // vertical: authMode == 0 ? 100 : 50,
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Text(
                                                        authMode == 0 ? "Welcome Back" : "Create Account",
                                                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                          color: AppColors.textSecondary,
                                                          fontSize: 16
                                                          ),
                                                      ),
                                                    SizedBox(
                                                      height: authMode == 0? 8:4,
                                                    ),
                                                  if (authMode == 1) ...[
                                                    TextFormFieldBuilder().fieldBuilder(
                                                      fieldController: authNameController,
                                                      hinttext: "Name",
                                                      fieldicon: Icons.person,
                                                    ),
                                                    // SizedBox(height: 2),
                                                  ],
                                            
                                                  TextFormFieldBuilder().fieldBuilder(
                                                    fieldController: authEmailController,
                                                    hinttext: "example@gmail.com",
                                                    fieldicon: Icons.email,
                                                  ),
                                                  // SizedBox(height: 2),
                                            
                                                  TextFormFieldBuilder().fieldBuilder(
                                                    fieldController: authPasswordController,
                                                    hinttext: "Password",
                                                    fieldicon: Icons.key,
                                                  ),
                                                  // SizedBox(height: 2),
                                            
                                                  if (authMode == 1) ...[
                                                    TextFormFieldBuilder().fieldBuilder(
                                                      fieldController: authConfirmPasswordController,
                                                      hinttext: "Confirm Password",
                                                      fieldicon: Icons.key,
                                                    ),
                                                    // SizedBox(height: 2),
                                                  ],
                                                  SizedBox(height: 8,),
                                            
                                                  SizedBox(
                                                    width: isMobile? 260 : 320,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () async {
                                                            if (authMode == 0) {
                                                              if (authEmailController.text.trim().isEmpty ||
                                                                  authPasswordController.text.trim().isEmpty) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackbarBuilder().snackbarBuilder(
                                                                    content: "Please fill both the details",
                                                                  ),
                                                                );
                                                              } else if (!authEmailController.text.contains('@') ||
                                                                  !authEmailController.text.contains('.')) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackbarBuilder().snackbarBuilder(
                                                                    content: "Please Enter a Valid email",
                                                                  ),
                                                                );
                                                              } else {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackbarBuilder().snackbarBuilder(
                                                                    content: "Login in Process",
                                                                  ),
                                                                );
                                            
                                                                if (authFormKey.currentState!.validate()) {
                                                                  final success = await auth.login(
                                                                    authEmailController.text,
                                                                    authPasswordController.text,
                                                                  );
                                            
                                                                  authPasswordController.clear();
                                                                  if (!context.mounted) return;
                                            
                                                                  if (success) {
                                                                    final authprovider =
                                                                        context.read<AuthProvider>();
                                                                    final userprovider =
                                                                        context.read<Userprovider>();
                                                                    final workspaceprovider =
                                                                        context.read<Workspaceprovider>();
                                            
                                                                    await authprovider.isLoggedIn(
                                                                        userprovider, workspaceprovider);
                                            
                                                                    authEmailController.clear();
                                                                    authConfirmPasswordController.clear();
                                                                    authNameController.clear();
                                                                    authPasswordController.clear();
                                                                  }
                                                                }
                                                              }
                                                            } else if (authMode == 1) {
                                                              switchToLogin();
                                                            }
                                                          },
                                                          child: Text(
                                                            "Login",
                                                            style: TextStyle(fontSize: 14),
                                                          ),
                                                        ),
                                            
                                                        SizedBox(width: 12),
                                            
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            if (authMode == 0) {
                                                              switchToSignUp();
                                                            } else if (authMode == 1) {
                                                              if (authNameController.text.trim().isEmpty ||
                                                                  authEmailController.text.trim().isEmpty ||
                                                                  authPasswordController.text.trim().isEmpty ||
                                                                  authConfirmPasswordController.text.trim().isEmpty) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackbarBuilder().snackbarBuilder(
                                                                    content: "Please fill all the details!",
                                                                  ),
                                                                );
                                                              } else if (!authEmailController.text.contains('@') ||
                                                                  !authEmailController.text.contains('.')) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackbarBuilder().snackbarBuilder(
                                                                    content: "Please Enter a Valid email!",
                                                                  ),
                                                                );
                                                              } else if (authPasswordController.text !=
                                                                  authConfirmPasswordController.text) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackbarBuilder().snackbarBuilder(
                                                                    content:
                                                                        "Please Enter same password in both fields!",
                                                                  ),
                                                                );
                                                              } else {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackbarBuilder().snackbarBuilder(
                                                                    content: "Account Successfully Created!",
                                                                  ),
                                                                );
                                            
                                                                if (authFormKey.currentState!.validate()) {
                                                                  final success = await auth.signUp(
                                                                    authNameController.text,
                                                                    authEmailController.text,
                                                                    authPasswordController.text,
                                                                    authConfirmPasswordController.text,
                                                                  );
                                            
                                                                  if (!context.mounted) return;
                                            
                                                                  if (success) {
                                                                    final authprovider =
                                                                        context.read<AuthProvider>();
                                                                    final userprovider =
                                                                        context.read<Userprovider>();
                                                                    final workspaceprovider =
                                                                        context.read<Workspaceprovider>();
                                            
                                                                    await authprovider.isLoggedIn(
                                                                        userprovider, workspaceprovider);
                                            
                                                                    authEmailController.clear();
                                                                    authNameController.clear();
                                                                    authPasswordController.clear();
                                                                    authConfirmPasswordController.clear();
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          },
                                                          child: Text("Sign Up"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                                                    ),
                                          )
                                                                
                                                          
                                      ),
                                                            
                                    ],
                                  ),
                                ],
                              ),
                              ),
                             
                          ],
                        ),

                        ),
                      ),
                      ),

                     // SizedBox(height: 32),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        tooltip: 'GitHub',
                                        icon: FaIcon(
                                            FontAwesomeIcons.github,
                                            size: 30,
                                      ),
                                          onPressed: () {
                                            final githubLink = 'https://github.com/Gurjotsofficial';
                                            openLink(githubLink);
                                          },
                                      ),
                                      SizedBox(width: 12),
                                      IconButton(
                                        tooltip: 'LinkedIn',
                                        icon: FaIcon(
                                              FontAwesomeIcons.linkedin,
                                              size: 30,
                                        ),
                                          onPressed: () {
                                            final linkedInLink = 'https://www.linkedin.com/in/gurjot-singh-71438a3b5/';
                                            openLink(linkedInLink);
                                          },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,)]
                  ),
                );
    })
        ),
      ),
    );
    }
  },
);

    


  }


  // OPEN LINK FUNCTION
  Future<void> openLink(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}



Route smoothRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final offset = Tween<Offset>(
        begin: Offset(0, 0.05),
        end: Offset.zero,
      ).animate(animation);

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: offset,
          child: child,
        ),
      );
    },
  );
}


}