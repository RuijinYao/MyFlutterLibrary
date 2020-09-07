import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_flutter_library/util/Constant.dart';
import 'package:my_flutter_library/util/Utils.dart';

import 'package:my_flutter_library/widget/CommonWidget.dart';
import 'package:sp_util/sp_util.dart';

class SignInPage extends StatefulWidget {
  @override
  createState() {
    return SignInPageState();
  }
}

class SignInPageState extends State<SignInPage> {
  bool isShowPassWord = false;

  FocusScopeNode focusScopeNode;
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  TextEditingController _pwdController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  GlobalKey<FormState> _signInFormKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(children: <Widget>[
            //创建表单
            buildSignInTextForm(),

            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    decoration: TextDecoration.underline),
              ),
            ),

            // Or所在的一行
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 1,
                    width: 100,
                    decoration: BoxDecoration(
                        gradient: new LinearGradient(colors: [
                      Colors.white10,
                      Colors.white,
                    ])),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: new Text(
                      "Or",
                      style: new TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: 100,
                    decoration: BoxDecoration(
                        gradient: new LinearGradient(colors: [
                      Colors.white,
                      Colors.white10,
                    ])),
                  ),
                ],
              ),
            ),

            //显示第三方登录的按钮
            Padding(
              padding: EdgeInsets.only(top: 10),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(icon: Icon(
                      FontAwesomeIcons.facebookF, color: Color(0xFF0084ff),),
                        onPressed: null),
                  ),
                  SizedBox(width: 40,),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(icon: Icon(
                      FontAwesomeIcons.google, color: Color(0xFF0084ff),),
                        onPressed: null),
                  ),
                ],
              ),
            )
          ]),

          Positioned(top: 190.h, child: buildSignInButton())
        ],
      ),
    );
  }

  /// 创建登录界面的TextForm
  Widget buildSignInTextForm() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white
      ),
      width: 500.w,
      height: 220.h,
      /**
       * Flutter提供了一个Form widget，它可以对输入框进行分组，
       * 然后进行一些统一操作，如输入内容校验、输入框重置以及输入内容保存。
       */
      child: Form(
        key: _signInFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[

            CommonWidget.buildTextForm(
              controller: _emailController,
              hintText: "Email Address",
              icon: Icon(Icons.email, color: Colors.black),
              focusNode: emailFocusNode,
              validator: (value) {
                if (value.isEmpty) {
                  return "Email can not be empty!";
                }
                return null;
              },
              //点击键盘上的完成/回车按钮, 自动聚焦到密码输入框
              onEditingComplete: () {
                if (focusScopeNode == null) {
                  focusScopeNode = FocusScope.of(context);
                }
                focusScopeNode.requestFocus(passwordFocusNode);
              },
            ),

            CommonWidget.buildLine(),

            CommonWidget.buildTextForm(
              controller: _pwdController,
              hintText: "Password",
              icon: Icon(Icons.lock_outline, color: Colors.black),
              focusNode: passwordFocusNode,
              obscure: isShowPassWord,
              suffixIcon: Icon(Icons.remove_red_eye, color: Colors.black),
              suffixOnPress: showPassWord,
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return "Password'length must longer than 6!";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 创建登录界面的按钮
  Widget buildSignInButton() {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          gradient: LinearGradient(
              colors: [Color(0xFF2175E9), Color(0x7721B7E9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Text(
          "LOGIN",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
      onTap: () {
        /**利用key来获取widget的状态FormState
            可以用过FormState对Form的子孙FromField进行统一的操作
         */
        if (_signInFormKey.currentState.validate()) {
          //如果输入都检验通过，则进行登录操作
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("执行登录操作")));
          //调用所有自孩子的save回调，保存表单内容
          _signInFormKey.currentState.save();
        }

        //todo 网络请求登录,
        // 密码实现MD5加密
        Utils.generateMd5(_pwdController.text.trim());

        SpUtil.putBool(Constant.hasLogin, true);
        SpUtil.putString(Constant.token, "token");
      },
    );
  }

  showPassWord() {
    setState(() {
      isShowPassWord = !isShowPassWord;
    });
  }
}
