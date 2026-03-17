import 'package:collab_code_editor/execution/execution_provider.dart';
import 'package:collab_code_editor/presence/presenceprovider.dart';
import 'package:collab_code_editor/services/authprovider.dart';
import 'package:collab_code_editor/user/userprovider.dart';
import 'package:collab_code_editor/views/landing_page.dart';
import 'package:collab_code_editor/workspace/activeworkspaceprovider.dart';
import 'package:collab_code_editor/workspace/workspaceprovider.dart';
import 'package:collab_code_editor/workspace_document/workspacedocumentprovider.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => Userprovider()),
        ChangeNotifierProvider(create: (_) => Workspaceprovider()),
        ChangeNotifierProvider(create: (_) => ActiveWorkspaceProvider()),
        ChangeNotifierProvider(create: (_) => WorkspaceDocumentProvider()),
        ChangeNotifierProvider(create: (_) => ExecutionProvider()),
        ChangeNotifierProvider(create: (_) => PresenceProvider()),
        
        ],
      child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Collabrative Coding',
      home: const LandingPage(),


      theme: ThemeData(
        useMaterial3: true,
      )
    ),
    );
      //   // This is the theme of your application.
      //   //
      //   // TRY THIS: Try running your application with "flutter run". You'll see
      //   // the application has a purple toolbar. Then, without quitting the app,
      //   // try changing the seedColor in the colorScheme below to Colors.green
      //   // and then invoke "hot reload" (save your changes or press the "hot
      //   // reload" button in a Flutter-supported IDE, or press "r" if you used
      //   // the command line to start the app).
      //   //
      //   // Notice that the counter didn't reset back to zero; the application
      //   // state is not lost during the reload. To reset the state, use hot
      //   // restart instead.
      //   //
      //   // This works for code too, not just values: Most code changes can be
      //   // tested with just a hot reload.
      //   colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 106, 6, 34)),
      // ),
  }
}

