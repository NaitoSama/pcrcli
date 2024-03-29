import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pcrcli/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global.dart';
import 'login.dart';

class StartUp extends StatefulWidget {
  const StartUp({super.key});

  @override
  State<StartUp> createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> {
  final ipAdd = TextEditingController();
  final port = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  Future<bool> getUrl(String ip,String port) async {
    if ( ip=='' || port=='' ){
      return false;
    }
    try {
      Uri uri = Uri.parse('$httpProtocol://$ip:$port/test');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // 返回真，表示响应代码为200
        return true;
      } else {
        // 返回假，表示响应代码非200
        return false;
      }
    } catch (e) {
      // 请求过程中发生异常，也返回假
      return false;
    }
  }
  Future<void> setUrl(String ip,String port) async {
    String url = '$httpProtocol://$ip:$port';
    // Load and obtain the shared preferences for this app.
    // final prefs = await SharedPreferences.getInstance();

    // Save the counter value to persistent storage under the 'counter' key.
    // await prefs.setString('url', url);
    GetxSettings getxSettings = Get.find<GetxSettings>();
    getxSettings.appSettings.value.remoteServerUrl = url;
    getxSettings.appSettings.value.isUrlConfirmed = true;
    getxSettings.updateSettings(getxSettings.appSettings.value);
  }
  Future<void> wrongAddDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("服务器连接失败"),
          content: Text("检查服务器是否运行，网络是否可达"),
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
  Future<void> _commit()async{
    var cancel1 = BotToast.showLoading();
    bool result = await getUrl(ipAdd.text,port.text);
    if(result){
      await setUrl(ipAdd.text, port.text);
      cancel1();
      // todo go to login page
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login', // home 页面的路由名称
            (route) => false, // 移除条件，始终为 false，表示移除所有页面
      );
    }else{
      cancel1();
      wrongAddDialog();
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(50, 50, 50, 35),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.6,
                    height: MediaQuery.sizeOf(context).height * 0.28,
                    decoration: const BoxDecoration(
                      // color: Colors.blue,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'images/64135784.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
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
                      controller: ipAdd,
                      obscureText: false,
                      onEditingComplete: (){
                        FocusScope.of(context).requestFocus(focusNode1);
                      },
                      decoration: InputDecoration(
                        labelText: 'IP Address',
                        hintText: 'Enter IP address...',
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
                      onEditingComplete: (){
                        _commit();
                      },
                      focusNode: focusNode1,
                      controller: port,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: 'Port',
                        hintText: 'Enter Port...',
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
                      // width: MediaQuery.sizeOf(context).width * 0.6,
                      // height: MediaQuery.sizeOf(context).height * 0.1,
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
                            // final prefs = await SharedPreferences.getInstance();
                            // String? url = await prefs.getString('url');
                            // print(url);
                            // String address = ipAdd.text + ':' + port.text;
                            _commit();
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
      ),
    );
  }
}
