import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:pcrcli/main.dart';
import 'package:pcrcli/register.dart';
import 'package:http/http.dart' as http;
import 'package:pcrcli/settings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'boss.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final username = TextEditingController();
  final password = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  Future<bool> sendLoginRequest(String username, String password) async {
    // final prefs = await SharedPreferences.getInstance();
    // var uri = prefs.getString('url');
    GetxSettings getxSettings = Get.find<GetxSettings>();
    final url = Uri.parse('${getxSettings.appSettings.value.remoteServerUrl}/login'); // 替换成你的登录接口URL
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final Map<String, dynamic> requestBody = {
      'username': username,
      'password': password,
    };
    // var box = await Hive.openBox('settingsBox');
    // AppSettings appSettings = box.get('settings');

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // 登录成功，保存cookie值
        String cookie = response.headers['set-cookie'] ?? '';
        var temp = cookie.split('pekoToken=');
        cookie = temp[temp.length-1].split(';')[0];
        // await prefs.setString('token', cookie);
        // appSettings.token = cookie;
        GetxSettings getxSettings = Get.find<GetxSettings>();
        getxSettings.appSettings.value.token = cookie;
        getxSettings.updateSettings(getxSettings.appSettings.value);
        print('Login successful. Cookie: $cookie');

        final Map<String, String> json = {
          'jwt': cookie,
        };
        response = await http.post(
          Uri.parse('${getxSettings.appSettings.value.remoteServerUrl}/userinfo'),
          headers: headers,
          body: jsonEncode(json)
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          // prefs.setInt('user_id', jsonResponse['user_id']);
          // prefs.setString('username', jsonResponse['username']);
          // prefs.setInt('user_authority', jsonResponse['user_authority']);
          // appSettings.username = jsonResponse['username'];
          // appSettings.authority = jsonResponse['user_authority'];
          // box.put('settings', appSettings);
          GetxSettings getxSettings = Get.find<GetxSettings>();
          getxSettings.appSettings.value.username = jsonResponse['username'];
          getxSettings.appSettings.value.authority = jsonResponse['user_authority'];
          getxSettings.appSettings.value.isLoggedIn = true;
          getxSettings.updateSettings(getxSettings.appSettings.value);
          return true;
        }else{
          return false;
        }


      } else {
        // 登录失败，处理错误
        print('Login failed. Status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      // 请求发生异常
      print('Error during login request: $error');
      return false;
    }
  }
  Future<void> wrongLoginDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("登陆失败"),
          content: Text("检查账号密码是否正确"),
          actions: <Widget>[
            TextButton(
              child: Text("确认"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
          ],
        );
      },
    );
  }
  Future<void> _login() async {
    var cancel1 = BotToast.showLoading();
    if(await sendLoginRequest(username.text,password.text)){
      cancel1();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home', // home 页面的路由名称
            (route) => false, // 移除条件，始终为 false，表示移除所有页面
      );
    }else{
      cancel1();
      wrongLoginDialog();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/QQ20240119162745.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Align(
        alignment: const AlignmentDirectional(0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height * 0.3,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.8,
              height: MediaQuery.sizeOf(context).height * 0.4,
              decoration: const BoxDecoration(
                // color: Colors.blue,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextFormField(
                    onEditingComplete: (){
                      FocusScope.of(context).requestFocus(focusNode1);
                    },
                    controller: username,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter Username...',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF59BCF8),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                    ),
                  ),
                  // Container(
                  //   height: 20,
                  // ),
                  TextFormField(
                    focusNode: focusNode1,
                    onEditingComplete: (){
                      _login();
                    },
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Password...',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF59BCF8),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0x00000000),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                    ),
                  ),
                  // Container(
                  //   height: 20,
                  // ),
                  Container(
                      width: 160,
                      height: 60,
                      decoration: const BoxDecoration(
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                        child: TextButton(
                          style: ButtonStyle(
                            // backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                            // foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                            side: MaterialStateProperty.all<BorderSide>(
                              const BorderSide(color: Color(0xFF59BCF8), width: 2),
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),

                          onPressed: () async {
                            // 按钮被点击时执行的操作
                            _login();

                          },

                          child: const Text(
                            'Commit',
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              color: Color(0xFF59BCF8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                    child: RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(
                              color: Colors.black,
                            )
                          ),
                          TextSpan(
                            text: ' Sign Up here',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                            mouseCursor: SystemMouseCursors.click,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigate to the registration page
                                Navigator.pushNamed(context, '/register');
                              },
                          )
                        ],
                        ),
                      ),
                    ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
