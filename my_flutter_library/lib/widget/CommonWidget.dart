import 'package:flutter/material.dart';

class CommonWidget{

  static Widget buildTextForm(
      {String hintText, Icon icon, bool obscure = true, Icon suffixIcon, FocusNode focusNode, Function suffixOnPress, FormFieldValidator<String> validator, Function onEditingComplete}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: TextFormField(
            decoration: InputDecoration(
              icon: icon,
              hintText: hintText,
              border: InputBorder.none,
              suffixIcon: suffixIcon != null
                  ? IconButton(icon: suffixIcon, onPressed: suffixOnPress)
                  : null,
            ),
            focusNode: focusNode ??= null,
            //输入密码，需要用*****显示
            obscureText: obscure,
            style: TextStyle(fontSize: 16, color: Colors.black),
            validator: validator,
            onEditingComplete: onEditingComplete,
        ),
      ),
    );
  }

  static Widget buildLine(){
    return Container(
      height: 1,
      width: 250,
      color: Colors.grey[400],
    );
  }
}