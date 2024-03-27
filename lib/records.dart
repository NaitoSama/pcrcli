import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pcrcli/main.dart';
import 'package:pcrcli/settings.dart';

class RecordsPage extends StatelessWidget {
  RecordsPage({super.key});
  var homeData = Get.find<HomeData>();
  late recordsController recordsC;
  var bossList = ['1','2','3','4','5','未选择'];
  var userList = <String>['未选择'];
  late int visibleCount;

  List<String> _bossOrUserList() {
    if (recordsC.method.value=='bossid'){return bossList;}
    else if (recordsC.method.value=='username'){return userList;}
    else{return <String>['未选择'];}
  }

  // @override
  // void initState(){
  //   Get.put(recordsController());
  //   recordsC = Get.find<recordsController>();
  //   for (String element in homeData.users.keys) {userList.add(element);}
  //   for (Record i in homeData.records) {recordsC.records.add(i);}
  // }

  @override
  Widget build(BuildContext context) {
    Get.put(recordsController());
    recordsC = Get.find<recordsController>();
    for (String element in homeData.users.keys) {userList.add(element);}
    for (Record i in homeData.records) {recordsC.records.add(i);}
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        automaticallyImplyLeading: false,
        title: Text(
          'Rocords',
          style: TextStyle(color: Colors.black),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: Obx(() =>Column(
        children: [
          // 筛选部分
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter:'),
                DropdownButton<String>(
                  value: recordsC.method.value==''?'all':recordsC.method.value,
                  onChanged: (String? newValue) {
                    recordsC.method.value = newValue!;
                    recordsC.selected.value = '未选择';
                  },
                  items: <String>['bossid', 'username','all']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                // 选择关键词内容的下拉菜单
                DropdownButton<String>(
                  value: recordsC.selected.value,
                  onChanged: (String? newValue) {
                    recordsC.selected.value = newValue!;
                  },
                  items: _bossOrUserList()
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Sort by:'),
                      IconButton(
                        icon: Icon(Icons.sort),
                        onPressed: () {
                          recordsC.asc.value = !recordsC.asc.value;
                        },
                      ),
                      Text('${recordsC.asc.value}')
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 记录列表
          Obx(() =>Expanded(
            child: ListView.builder(
              itemCount: recordsC.records.length,
              itemBuilder: (context, index) {
                int i = 0;
                if(recordsC.asc.value){
                  i = index;
                }else{
                  i = recordsC.records.length - 1 - index;
                }
                if (recordsC.selected.value != '未选择'){
                  switch(recordsC.method.value){
                    case 'bossid': if(recordsC.selected.value != '${recordsC.records[i].attackTo}'){return const SizedBox.shrink();}
                    case 'username': if(recordsC.selected.value != recordsC.records[i].attackFrom){return const SizedBox.shrink();}
                  }
                }else if(recordsC.records[index].canUndo == 0){return const SizedBox.shrink();}

                return recordsCard(username: recordsC.records[i].attackFrom, bossID: recordsC.records[i].attackTo);
              },
            ),
          )),
        ],
      )),
    );
  }
}

class recordsCard extends StatelessWidget {
  String username;
  int bossID;
  var homeData = Get.find<HomeData>();
  var getx = Get.find<GetxSettings>();
  recordsCard({super.key,required this.username,required this.bossID});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height*0.1,
          width: MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
          child: ElevatedButton(
            onPressed: () {

            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: Colors.black,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 2,bottom: 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height*0.07,
                    height: MediaQuery.of(context).size.height*0.07,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: homeData.users[username]?.picEtag.value==''?Image.asset(
                            'images/64135784.png',
                            fit: BoxFit.cover,
                          ):Image.memory(
                              getx.appSettings.value.eTagToPic[homeData.users[username]?.picEtag.value]!,
                              fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4,bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('时间',
                        style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),
                      ),
                      SvgPicture.asset(
                        'images/swords.svg',
                        width: 25,
                        height: MediaQuery.of(context).size.height*0.04,
                      ),
                      Text('伤害',
                        style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 2,bottom: 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height*0.07,
                    height: MediaQuery.of(context).size.height*0.07,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            getx.appSettings.value.eTagToPic[homeData.bosses[bossID-1].picETag]!,
                            fit: BoxFit.cover,
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}


class recordsController extends GetxController {
  RxString method = ''.obs;
  RxString selected = '未选择'.obs;
  RxBool asc = true.obs;
  RxList<Record> records = <Record>[].obs;
}

