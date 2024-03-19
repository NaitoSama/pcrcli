import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcrcli/settings.dart';

class MyPage extends StatelessWidget {
  MyPage({super.key});
  var getx = Get.find<GetxSettings>();

  void _logout(){
    getx.appSettings.value.token = '';
    getx.appSettings.value.isLoggedIn = false;
    AppSettings appSettings = getx.appSettings.value;
    getx.updateSettings(appSettings);
    getx.homeSelectedIndex.value = 0;
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
                            child: Image.asset(
                              'images/64135784.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
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
                              '${getx.appSettings.value.username}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                              child: Obx(() => Text(
                                '用户级别: ${(getx.appSettings.value.authority == 0)?'普通用户':'管理员'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),)
                            ),
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
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    child: SizedBox(
                      height: 54,
                      width: MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
                      child: ElevatedButton(
                        onPressed: () {
                          var cancel1 = BotToast.showText(text:"功能还没做捏");
                          // 按钮点击事件
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 2,bottom: 0),
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
                    )
                  ),
                  Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                      child: SizedBox(
                        height: 54,
                        width: MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
                        child: ElevatedButton(
                          onPressed: () {
                            var cancel1 = BotToast.showText(text:"功能还没做捏");
                            // 按钮点击事件
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.black,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 2,bottom: 0),
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
                      )
                  ),
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
                            onPressed: (){
                              _logout();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login', // home 页面的路由名称
                                    (route) => false, // 移除条件，始终为 false，表示移除所有页面
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white, // 设置按钮背景颜色为白色
                              onPrimary: Colors.black, // 设置按钮文字颜色为黑色
                              elevation: 5, // 设置按钮的阴影高度
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // 设置按钮圆角
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
