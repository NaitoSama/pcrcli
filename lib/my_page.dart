import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pcrcli/common.dart';
import 'package:pcrcli/main.dart';
import 'package:pcrcli/my_page.logic.dart';
import 'package:pcrcli/settings.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';

class MyPage extends StatelessWidget {
  MyPage({super.key});
  var getx = Get.find<GetxSettings>();
  var homeData = Get.find<HomeData>();
  var wsc = Get.find<WSC>();
  var myPageLogic = MyPageLogic();
  final TextEditingController archiveNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  void _logout() {
    // clean appSettings
    getx.appSettings.value.token = '';
    getx.appSettings.value.isLoggedIn = false;
    AppSettings appSettings = getx.appSettings.value;
    getx.updateSettings(appSettings);
    getx.homeSelectedIndex.value = 0;
    // clean ws
    wsc.ws.sink.close();
    wsc.isConnected = false;
    wsc.connect();
  }

  Future<bool> _userPic() async {
    if (getx.appSettings.value.eTagToPic.containsKey(
        homeData.users[getx.appSettings.value.username]?.picEtag.value)) {
      return true;
    } else if (homeData.users[getx.appSettings.value.username]?.picEtag.value ==
        '') {
      return false;
    } else {
      final response = await http.get(Uri.parse(
          '${getx.appSettings.value.remoteServerUrl}/pic/${homeData.users[getx.appSettings.value.username]?.picEtag.value}.jpg'));
      if (response.statusCode == 200) {
        getx.appSettings.value.eTagToPic[homeData
            .users[getx.appSettings.value.username]!
            .picEtag
            .value] = response.bodyBytes;
        getx.updateSettings(getx.appSettings.value);
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFFFAFAFA),
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     'Clan Battle',
      //     style: TextStyle(color: Colors.black),
      //   ),
      //   actions: [],
      //   centerTitle: false,
      //   elevation: 0,
      // ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Generated code for this Container Widget...
              Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Color(0xFFFFAFAFA),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      color: Color(0xFFFFAFAFA),
                      offset: Offset(0, 0),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FutureBuilder(
                                future: _userPic(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.data == true) {
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  onLongPress: () async {
                                                    int timestamp = DateTime
                                                            .now()
                                                        .millisecondsSinceEpoch;
                                                    var result = await ImageGallerySaver
                                                        .saveImage(
                                                            getx
                                                                    .appSettings
                                                                    .value
                                                                    .eTagToPic[
                                                                homeData
                                                                    .users[getx
                                                                        .appSettings
                                                                        .value
                                                                        .username]
                                                                    ?.picEtag
                                                                    .value]!,
                                                            name:
                                                                '${timestamp}_${getx.appSettings.value.username}',
                                                            quality: 100);
                                                    if (result['isSuccess'] ==
                                                        true) {
                                                      var ok =
                                                          BotToast.showText(
                                                              text: '保存成功');
                                                    } else {
                                                      var fail =
                                                          BotToast.showText(
                                                              text: '保存失败');
                                                    }
                                                  },
                                                  child: PhotoView(
                                                      imageProvider:
                                                          MemoryImage(getx
                                                                  .appSettings
                                                                  .value
                                                                  .eTagToPic[
                                                              homeData
                                                                  .users[getx
                                                                      .appSettings
                                                                      .value
                                                                      .username]
                                                                  ?.picEtag
                                                                  .value]!)),
                                                );
                                              });
                                        },
                                        child: Image.memory(
                                          getx.appSettings.value.eTagToPic[
                                              homeData
                                                  .users[getx.appSettings.value
                                                      .username]
                                                  ?.picEtag
                                                  .value]!,
                                          width: 16,
                                          height: 16,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      return Image.asset(
                                        'images/64135784.png',
                                        width: 16,
                                        height: 16,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                }),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Characters(getx.appSettings.value.username)
                                          .length >
                                      14
                                  ? '${Characters(getx.appSettings.value.username).take(14)}...'
                                  : getx.appSettings.value.username,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                child: Obx(
                                  () => Text(
                                    '用户级别: ${(getx.appSettings.value.authority == 0) ? '普通用户' : ((getx.appSettings.value.authority == 1) ? '管理员' : '超级管理员')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: const Color(0xFFF1F4F8),
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 12, 0, 12),
                  child: Text(
                    'Account Settings',
                    style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Generated code for this Column Widget...
          Expanded(
            child: Container(
              color: const Color(0xFFF1F4F8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                      child: SizedBox(
                        height: 54,
                        width:
                            MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _passwordChangeDialog(),
                            );
                            // var cancel1 = BotToast.showText(text:"功能还没做捏");
                            // 按钮点击事件
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 2, bottom: 0),
                                child: Text(
                                  '修改密码',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 2),
                                child: Icon(Icons.keyboard_arrow_right),
                              ),
                            ],
                          ),
                        ),
                      )),
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                      child: SizedBox(
                        height: 54,
                        width:
                            MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
                        child: ElevatedButton(
                          onPressed: () async {
                            bool result = await myPageLogic.pickImage(
                                getx.appSettings.value.remoteServerUrl,
                                getx.appSettings.value.token);
                            if (result) {
                              var cancel1 = BotToast.showText(text: "上传成功");
                              await myPageLogic.updateMyPic();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home', // home 页面的路由名称
                                (route) => false, // 移除条件，始终为 false，表示移除所有页面
                              );
                            } else {
                              var cancel1 = BotToast.showText(text: "上传失败");
                            }

                            // 按钮点击事件
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 2, bottom: 0),
                                child: Text(
                                  '修改头像',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 2),
                                child: Icon(Icons.keyboard_arrow_right),
                              ),
                            ],
                          ),
                        ),
                      )),
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                      child: Visibility(
                        visible: (getx.appSettings.value.authority > 1),
                        child: SizedBox(
                          height: 54,
                          width:
                              MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 10,
                                    title: Text('归档确认'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: archiveNameController,
                                          decoration: const InputDecoration(
                                            labelText: '记录归档的档案名称',
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 20),
                                          child:
                                              Text('你确定要将记录归档并重置会战吗？\n该操作不可逆！'),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('不了'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10, right: 8),
                                        child: TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            var sendReq = SendReq(1,
                                                '${getx.appSettings.value.remoteServerUrl}/v1/archiverecords',
                                                query: <String, String>{
                                                  'archive_name':
                                                      archiveNameController.text
                                                },
                                                token: getx
                                                    .appSettings.value.token);
                                            var resp = await sendReq.send();
                                            if (resp?.statusCode == 200) {
                                              var cancel1 = BotToast.showText(
                                                  text: "重置成功，重启app查看");
                                            } else {
                                              var cancel1 = BotToast.showText(
                                                  text: "重置失败");
                                            }
                                          },
                                          child: Text('确定'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 2, bottom: 0),
                                  child: Text(
                                    '归档记录并重置会战',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 2),
                                  child: Icon(Icons.keyboard_arrow_right),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                      child: Visibility(
                        visible: (getx.appSettings.value.authority > 1),
                        child: SizedBox(
                          height: 54,
                          width:
                              MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 10,
                                    title: Text('设置成员管理员权限'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: usernameController,
                                          decoration: const InputDecoration(
                                            labelText: '用户名称',
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 20),
                                          child: Text(
                                              '将该成员设置为管理员（没有重置会战和设置管理员权限）？'),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('不了'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10, right: 8),
                                        child: TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            var sendReq = SendReq(1,
                                                '${getx.appSettings.value.remoteServerUrl}/v1/updateuserauthority',
                                                query: <String, String>{
                                                  'username':
                                                      usernameController.text
                                                },
                                                token: getx
                                                    .appSettings.value.token);
                                            var resp = await sendReq.send();
                                            if (resp?.statusCode == 200) {
                                              var cancel1 = BotToast.showText(
                                                  text: "设置成功");
                                            } else {
                                              var cancel1 = BotToast.showText(
                                                  text: "重置失败");
                                            }
                                          },
                                          child: Text('确定'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 2, bottom: 0),
                                  child: Text(
                                    '设成员为管理员',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 2),
                                  child: Icon(Icons.keyboard_arrow_right),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 37,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 10,
                                    title: Text('登出确认'),
                                    content: Text('你确定要登出吗？'),
                                    actions: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('不了'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10, right: 8),
                                        child: TextButton(
                                          onPressed: () {
                                            _logout();
                                            Navigator.of(context).pop();
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/login', // home 页面的路由名称
                                              (route) =>
                                                  false, // 移除条件，始终为 false，表示移除所有页面
                                            );
                                          },
                                          child: Text('确定'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white, // 设置按钮文字颜色为黑色
                              elevation: 5, // 设置按钮的阴影高度
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // 设置按钮圆角
                              ),
                            ),
                            child: const Text('登出'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 1,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home),label: 'home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person),label: 'mine'),
      //   ],
      //   onTap: (int index){
      //     switch(index){
      //       case 0: Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);break;
      //       case 1: {
      //         if(ModalRoute.of(context)?.settings.name == '/my_page'){
      //           break;
      //         }
      //         Navigator.pushNamedAndRemoveUntil(context, '/my_page', (route) => false);break;
      //       }
      //
      //     }
      //   },
      // ),
    );
  }
}

class _passwordChangeDialog extends StatelessWidget {
  final FocusNode passwdFocus = FocusNode();
  final FocusNode repasswdFocus = FocusNode();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  var getx = Get.find<GetxSettings>();
  var myPageLogic = MyPageLogic();
  void _logout() {
    getx.appSettings.value.token = '';
    getx.appSettings.value.isLoggedIn = false;
    AppSettings appSettings = getx.appSettings.value;
    getx.updateSettings(appSettings);
    getx.homeSelectedIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      title: Text('修改密码'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(passwdFocus);
            },
            controller: oldPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '旧密码',
            ),
          ),
          TextField(
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(repasswdFocus);
            },
            focusNode: passwdFocus,
            controller: newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '新密码',
            ),
          ),
          TextField(
            onEditingComplete: () async {
              String oldPassword = oldPasswordController.text;
              String newPassword = newPasswordController.text;
              String repeatPassword = repeatPasswordController.text;

              if (newPassword == repeatPassword) {
                // 密码一致，进行提交操作
                bool result = await myPageLogic.changePassword(
                    getx.appSettings.value.remoteServerUrl,
                    getx.appSettings.value.username,
                    getx.appSettings.value.token,
                    oldPassword,
                    newPassword);
                if (result) {
                  var cancel1 = BotToast.showText(text: "更改密码成功，跳转至登录页面");
                  _logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login', // home 页面的路由名称
                    (route) => false, // 移除条件，始终为 false，表示移除所有页面
                  );
                } else {
                  var cancel1 = BotToast.showText(text: "更改密码失败");
                  Navigator.of(context).pop();
                }

                // Navigator.of(context).pop(); // 关闭对话框
              } else {
                var cancel1 = BotToast.showText(text: "重复输入新密码不一致");
              }
            },
            focusNode: repasswdFocus,
            controller: repeatPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '重复新密码',
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 10),
          child: ElevatedButton(
            onPressed: () async {
              String oldPassword = oldPasswordController.text;
              String newPassword = newPasswordController.text;
              String repeatPassword = repeatPasswordController.text;

              if (newPassword == repeatPassword) {
                // 密码一致，进行提交操作
                bool result = await myPageLogic.changePassword(
                    getx.appSettings.value.remoteServerUrl,
                    getx.appSettings.value.username,
                    getx.appSettings.value.token,
                    oldPassword,
                    newPassword);
                if (result) {
                  var cancel1 = BotToast.showText(text: "更改密码成功，跳转至登录页面");
                  _logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login', // home 页面的路由名称
                    (route) => false, // 移除条件，始终为 false，表示移除所有页面
                  );
                } else {
                  var cancel1 = BotToast.showText(text: "更改密码失败");
                  Navigator.of(context).pop();
                }

                // Navigator.of(context).pop(); // 关闭对话框
              } else {
                var cancel1 = BotToast.showText(text: "重复输入新密码不一致");
              }
            },
            child: Text('提交'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // 清理控制器
    oldPasswordController.dispose();
    newPasswordController.dispose();
    repeatPasswordController.dispose();
  }
}
