import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

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
              Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
                )
              ),
            ],
          ),
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
