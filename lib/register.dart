import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:pcrcli/register.dart';
import 'package:http/http.dart' as http;
import 'package:pcrcli/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'boss.dart';
import 'main.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  final username = TextEditingController();
  final password = TextEditingController();
  final code = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();

  Future<bool> sendRegisterRequest(String username, String password, String code) async {
    // final prefs = await SharedPreferences.getInstance();
    // var uri = prefs.getString('url');
    GetxSettings getxSettings = Get.find<GetxSettings>();
    final url = Uri.parse('${getxSettings.appSettings.value.remoteServerUrl}/register'); // 替换成你的登录接口URL
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final Map<String, dynamic> requestBody = {
      'username': username,
      'password': password,
      'register_code':code,
    };

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // 注册成功，保存cookie值
        String cookie = response.headers['set-cookie'] ?? '';
        var temp = cookie.split('pekoToken=');
        cookie = temp[temp.length-1].split(';')[0];
        // await prefs.setString('token', cookie);
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
          // var box = await Hive.openBox('settingsBox');
          // AppSettings appSettings = box.get('settings');
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
        // 注册失败，处理错误
        print('Login failed. Status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      // 请求发生异常
      print('Error during login request: $error');
      return false;
    }
  }
  Future<void> wrongRegisterDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("注册失败"),
          content: Text("检查名字是否含有“|”符号，名字是否重复"),
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
  Future<void> _register() async {
    var cancel1 = BotToast.showLoading();
    if (await sendRegisterRequest(username.text, password.text, code.text)){
      cancel1();
      WSC wsc = Get.find<WSC>();
      await wsc.connect();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home', // home 页面的路由名称
            (route) => false, // 移除条件，始终为 false，表示移除所有页面
      );
    }else{
      cancel1();
      wrongRegisterDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('register'),
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
              height: MediaQuery.sizeOf(context).height * 0.3,
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
                      FocusScope.of(context).requestFocus(focusNode2);
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
                  TextFormField(
                    onEditingComplete: (){
                      _register();
                    },
                    focusNode: focusNode2,
                    controller: code,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Register code',
                      hintText: 'Enter code...',
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
                            _register();

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
