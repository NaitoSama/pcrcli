import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcrcli/settings.dart';

import 'boss.dart';
import 'my_page.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final getx = Get.find<GetxSettings>();
  Widget _buildBody() {
    switch (getx.homeSelectedIndex.value) {
      case 0:
        return bossPage();
      case 1:
        return MyPage();
      default:
        return Container(child: const Text('Page Not Defined'),); // 默认情况下返回一个空的 Container
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        automaticallyImplyLeading: false,
        title: Text(
          'Clan Battle',
          style: TextStyle(color: Colors.black),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        iconSize: 28,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: getx.homeSelectedIndex.value,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.shield_sharp),label: '会战'),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: '我的'),
        ],
        onTap: (int index){
          switch(index){
            case 0: {
              if(getx.homeSelectedIndex.value == 0){
                break;
              }
              getx.homeSelectedIndex.value = 0;
              // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);break;
            }
            case 1: {
              if(getx.homeSelectedIndex.value == 1){
                break;
              }
              getx.homeSelectedIndex.value = 1;
              // Navigator.pushNamedAndRemoveUntil(context, '/my_page', (route) => false);break;
            }
          }
        },
      )),
      body: Obx(() => _buildBody()),
    );
  }
}
