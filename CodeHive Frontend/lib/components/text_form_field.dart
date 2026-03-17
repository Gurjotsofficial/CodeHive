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
                    controller: fieldController,
                    // obscureText: true,
                      decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: hinttext,
                      prefixIcon: Icon(fieldicon),
                      border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                    ),
                   
              ],
            ),
          );
  }


}