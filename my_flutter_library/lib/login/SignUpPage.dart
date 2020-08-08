import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:my_flutter_library/widget/CommonWidget.dart';

class SignUpPage extends StatefulWidget {
  @override
  createState() {
    return SignUpPageState();
  }
}

class SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.white,
              ),
              width: 500.w,
              height: 400.h,
              child: buildSignUpTextForm()),
          Positioned(
            top: 380.h,
            child: Center(
              child: Container(
                padding:
                    EdgeInsets.symmetric(vertical: 15.h, horizontal: 50.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF2175E9), Color(0x7721B7E9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Text(
                  "SignUp",
                  style: new TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildSignUpTextForm() {
    return Form(
      child: Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        //用户名字
        CommonWidget.buildTextForm(
            hintText: "Name", icon: Icon(Icons.email, color: Colors.black)),

        CommonWidget.buildLine(),

        //邮箱
        CommonWidget.buildTextForm(
            hintText: "Email Address",
            icon: Icon(Icons.email, color: Colors.black)),

        CommonWidget.buildLine(),

        //密码
        CommonWidget.buildTextForm(
            hintText: "Password",
            icon: Icon(Icons.lock, color: Colors.black),
            suffixIcon: Icon(Icons.remove_red_eye, color: Colors.black),
            suffixOnPress: () {}),

        CommonWidget.buildLine(),

        //确认密码
        CommonWidget.buildTextForm(
            hintText: "Confirm Password",
            icon: Icon(Icons.lock, color: Colors.black),
            suffixIcon: Icon(Icons.remove_red_eye, color: Colors.black),
            suffixOnPress: () {})
      ],
    ));
  }


}
