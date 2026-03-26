import 'package:collab_code_editor/App_Theme/app_colors.dart';
import 'package:flutter/material.dart';

class TextFormFieldBuilder {

  Widget fieldBuilder( {
    required TextEditingController fieldController, 
    required String hinttext, 
    required IconData fieldicon,
    })
  {
   return  SizedBox(
            width: 320,
            height: 75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextFormField(
                  style: fieldTextStyle,
                    controller: fieldController,
                    // obscureText: true,
                      decoration: InputDecoration(
                      // filled: true,
                      // fillColor: Colors.white,
                      hintText: hinttext,
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14
                      ),
                      prefixIcon: Icon(fieldicon, color: AppTheme.darkTheme.iconTheme.color,),
                      border: AppTheme.darkTheme.inputDecorationTheme.border,
                      focusedBorder: AppTheme.darkTheme.inputDecorationTheme.focusedBorder,
                      enabledBorder: AppTheme.darkTheme.inputDecorationTheme.enabledBorder

                      
                    ),
            )]
              
            ),
          );
  }

  final fieldTextStyle = TextStyle(
    color: AppColors.textPrimary,
                    fontSize: 16,
  );


}