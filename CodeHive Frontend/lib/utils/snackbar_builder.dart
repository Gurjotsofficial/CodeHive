import 'package:collab_code_editor/App_Theme/app_colors.dart';
import 'package:flutter/material.dart';

class SnackbarBuilder {

  SnackBar snackbarBuilder({
    required String content,
  }){
    return SnackBar(content: Text(content,
    style: TextStyle(color: AppTheme.darkTheme.textTheme.bodyLarge!.color,
    fontSize: 14
    ),),
                    backgroundColor: AppColors.snackbar,
                    duration : Duration(seconds: 2),
              );
  }


}