import 'package:bot_toast/bot_toast.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:pcrcli/main.dart';
import 'package:pcrcli/settings.dart';
import 'package:photo_view/photo_view.dart';

import 'common.dart';

class RecordsPage extends StatelessWidget {
  RecordsPage({super.key});
  var homeData = Get.find<HomeData>();
  late recordsController recordsC;
  var bossList = ['1','2','3','4','5','未选择'];
  var userList = <String>['未选择'];
  late int visibleCount;
  final TextEditingController textEditingController = TextEditingController();

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
      body: Obx(() =>Container(
        color: Color(0xFFFAFAFA),
        child: Column(
          children: [
            // 筛选部分
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Text('筛选:'),
                  Container(
                    width: 94,
                    child: DropdownButton2<String>(
                      value: recordsC.method.value==''?'all':recordsC.method.value,
                      onChanged: (String? newValue) {
                        recordsC.method.value = newValue!;
                        recordsC.selected.value = '未选择';
                      },
                      items: <String>['bossid', 'username','all']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(
                            child: Text(
                              value,
                            ),
                          ),
                        );
                      }).toList(),
                      buttonStyleData: const ButtonStyleData(
                        height: 50,
                        width: 160,
                        padding: EdgeInsets.only(left: 14, right: 14),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          // color: Colors.redAccent,
                        ),
                        offset: const Offset(-20, 0),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: MaterialStateProperty.all(6),
                          thumbVisibility: MaterialStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                        padding: EdgeInsets.only(left: 14, right: 14),
                      ),
                    ),
                  ),
                  // 选择关键词内容的下拉菜单
                  Container(
                    width: 100,
                    child: DropdownButton2<String>(
                      value: recordsC.selected.value,
                      onChanged: (String? newValue) {
                        recordsC.selected.value = newValue!;
                      },
                      items: _bossOrUserList()
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(width: 100,child: Text(value,overflow: TextOverflow.ellipsis,)),
                        );
                      }).toList(),
                      dropdownSearchData: DropdownSearchData(
                        searchController: textEditingController,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: textEditingController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: 'Search for an item...',
                              hintStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return item.value.toString().contains(searchValue);
                        },
                      ),
                      buttonStyleData: const ButtonStyleData(
                        height: 50,
                        width: 160,
                        padding: EdgeInsets.only(left: 14, right: 14),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          // color: Colors.redAccent,
                        ),
                        offset: const Offset(-20, 0),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: MaterialStateProperty.all(6),
                          thumbVisibility: MaterialStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                        padding: EdgeInsets.only(left: 14, right: 14),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Text('Sort by:'),
                        IconButton(
                          icon: Icon(Icons.sort),
                          onPressed: () {
                            recordsC.asc.value = !recordsC.asc.value;
                          },
                        ),
                        TextButton(
                          child: Text('时间${recordsC.asc.value==false?'逆':'正'}序',),

                          onPressed: (){
                            recordsC.asc.value = !recordsC.asc.value;
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 记录列表
            Expanded(
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

                  return recordsCard(
                    username: recordsC.records[i].attackFrom,
                    bossID: recordsC.records[i].attackTo,
                    time: recordsC.records[i].createTime,
                    damage: recordsC.records[i].damage,
                    id: recordsC.records[i].id,
                  );
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class recordsCard extends StatelessWidget {
  String username;
  int bossID;
  String time;
  int damage;
  int id;
  var homeData = Get.find<HomeData>();
  var getx = Get.find<GetxSettings>();
  var recordsC = Get.find<recordsController>();
  recordsCard({super.key,required this.username,required this.bossID,required this.time,required this.damage,required this.id});

  String _parse_time(String time) {
    DateTime dateTime = DateTime.parse(time);
    DateTime utcPlus8DateTime = dateTime.toUtc().add(Duration(hours: 8));
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(utcPlus8DateTime);
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height*0.1,
          width: MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
          child: Slidable(
            enabled: (getx.appSettings.value.authority>0),
            // key: const ValueKey(0),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              // dismissible: DismissiblePane(key: key,onDismissed: (){},),
              children: [
                SlidableAction(
                  borderRadius: BorderRadius.circular(15),
                  onPressed: (_){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          elevation: 10,
                          title: const Text('删除确认'),
                          content: Text('确定要删除用户"$username"在${_parse_time(time)}对boss$bossID造成$damage伤害的记录吗？\n该操作不可逆'),
                          actions: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('不了'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10,right: 8),
                              child: TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  var sendReq = SendReq(1, '${getx.appSettings.value.remoteServerUrl}/v1/deleterecord',query: <String,String>{'record_id':'$id'},token: getx.appSettings.value.token);
                                  var resp = await sendReq.send();
                                  if(resp?.statusCode == 200){
                                    for (int i=0;i<homeData.records.length;i++){if(homeData.records[i].id==id){homeData.records.removeAt(i);}}
                                    for (int i=0;i<recordsC.records.length;i++){if(recordsC.records[i].id==id){recordsC.records.removeAt(i);}}
                                    var cancel1 = BotToast.showText(text:"删除成功");
                                  }else{
                                    var cancel1 = BotToast.showText(text:"重置失败");
                                  }
                                },
                                child: Text('确定'),
                              ),
                            ),
                          ],
                        );
                      }
                    );
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text:username));
                var cancel1 = BotToast.showText(text:'已复制：$username');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white,
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
                          GestureDetector(
                            onTap: (){
                              if(homeData.users[username]?.picEtag.value!=''){
                                showDialog(context: context, builder: (BuildContext context){
                                  return GestureDetector(
                                    onTap: (){Navigator.of(context).pop();},
                                    onLongPress: () async {
                                      int timestamp = DateTime.now().millisecondsSinceEpoch;
                                      var result = await ImageGallerySaver.saveImage(getx.appSettings.value.eTagToPic[homeData.users[username]?.picEtag.value]!,name: '${timestamp}_$username',quality: 100);
                                      if(result['isSuccess'] == true){
                                        var ok = BotToast.showText(text: '保存成功');
                                      }else{
                                        var fail = BotToast.showText(text: '保存失败');
                                      }
                                    },
                                    child: PhotoView(
                                        imageProvider:MemoryImage(getx.appSettings.value.eTagToPic[homeData.users[username]?.picEtag.value]!)
                                    ),
                                  );
                                });
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: homeData.users[username]?.picEtag.value==''?Image.asset(
                                'images/64135784.png',
                                fit: BoxFit.cover,
                              ):Image.memory(
                                  getx.appSettings.value.eTagToPic[homeData.users[username]?.picEtag.value]!,
                                  fit: BoxFit.cover,
                              ),
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
                        Text(_parse_time(time),
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),
                        ),
                        SvgPicture.asset(
                          'images/swords.svg',
                          width: 25,
                          height: MediaQuery.of(context).size.height*0.04,
                        ),
                        Text(NumberFormat('#,##0').format(damage),
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
                          GestureDetector(
                            onTap: (){
                                showDialog(context: context, builder: (BuildContext context){
                                  return GestureDetector(
                                    onTap: (){Navigator.of(context).pop();},
                                    onLongPress: () async {
                                      int timestamp = DateTime.now().millisecondsSinceEpoch;
                                      var result = await ImageGallerySaver.saveImage(getx.appSettings.value.eTagToPic[homeData.bosses[bossID-1].picETag]!,name: '${timestamp}_boss$bossID',quality: 100);
                                      if(result['isSuccess'] == true){
                                        var ok = BotToast.showText(text: '保存成功');
                                      }else{
                                        var fail = BotToast.showText(text: '保存失败');
                                      }
                                    },
                                    child: PhotoView(
                                        imageProvider:MemoryImage(getx.appSettings.value.eTagToPic[homeData.bosses[bossID-1].picETag]!)
                                    ),
                                  );
                                });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                getx.appSettings.value.eTagToPic[homeData.bosses[bossID-1].picETag]!,
                                fit: BoxFit.cover,
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}


class recordsController extends GetxController {
  RxString method = ''.obs;
  RxString selected = '未选择'.obs;
  RxBool asc = false.obs;
  RxList<Record> records = <Record>[].obs;
}

