import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pcrcli/register.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'boss.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  final username = TextEditingController();
  final password = TextEditingController();
  final code = TextEditingController();

  Future<bool> sendRegisterRequest(String username, String password, String code) async {
    var prefs = await SharedPreferences.getInstance();
    var uri = prefs.getString('url');
    final url = Uri.parse('${uri!}/register'); // 替换成你的登录接口URL
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final Map<String, dynamic> requestBody = {
      'username': username,
      'password': password,
      'register_code':code,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // 注册成功，保存cookie值
        String cookie = response.headers['set-cookie'] ?? '';
        var temp = cookie.split('pekoToken=');
        cookie = temp[temp.length-1].split(';')[0];
        await prefs.setString('token', cookie);
        print('Login successful. Cookie: $cookie');
        return true;
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
                            if (await sendRegisterRequest(username.text, password.text, code.text)){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => bossPage()),
                              );
                            }else{
                              wrongRegisterDialog();
                            }

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
