import 'package:collab_code_editor/App_Theme/app_colors.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class SnackbarBuilder {

  SnackBar snackbarBuilder({
    required String content,
  }){
    return SnackBar(content: Text(content,
    style: AppTheme.darkTheme.textTheme.bodyMedium!.copyWith(
      color: AppColors.textPrimary,
      fontSize: 14
    )
    ),

    backgroundColor: AppColors.snackbar,
    duration : Duration(seconds: 2),
    );
  }


}