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
import 'package:syncfusion_flutter_charts/charts.dart';

import 'common.dart';

class ChartPage extends StatelessWidget {
  ChartPage({super.key});
  var homeData = Get.find<HomeData>();
  late recordsController recordsC;
  var dateList = ['全部'];
  var userList = <String>['全部'];
  late int visibleCount;
  final TextEditingController textEditingController = TextEditingController();

  List<String> _bossOrUserList() {
    if (recordsC.method.value=='日期'){return dateList;}
    else if (recordsC.method.value=='用户名'){return userList;}
    else{return <String>['全部'];}
  }

  String _parse_time(String time) {
    DateTime dateTime = DateTime.parse(time);
    DateTime utcPlus8DateTime = dateTime.toUtc().add(Duration(hours: 8));
    String formattedDateTime = DateFormat('yyyy-MM-dd').format(utcPlus8DateTime);
    return formattedDateTime;
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
    for (Record i in homeData.records) {
      String datetimeStr = _parse_time(i.createTime);
      if (!dateList.contains(datetimeStr)){dateList.add(datetimeStr);}
      recordsC.records.add(i);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        automaticallyImplyLeading: false,
        title: Text(
          'Chart',
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Text('筛选:'),
                Container(
                  // width: 94,
                  child: DropdownButton2<String>(
                    value: recordsC.method.value==''?'全部':recordsC.method.value,
                    onChanged: (String? newValue) {
                      recordsC.method.value = newValue!;
                      recordsC.selected.value = '全部';
                    },
                    items: <String>['日期', '用户名','全部']
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
                Container(width: 20,),
                // 选择关键词内容的下拉菜单
                Container(
                  // width: 100,
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
              ],
            ),
          ),
          // 图表部分
          SingleChildScrollView(
            child: Chart(),
          ),
        ],
      )),
    );
  }
}

class Chart extends StatelessWidget {
  var homeData = Get.find<HomeData>();
  var getx = Get.find<GetxSettings>();
  var recordsC = Get.find<recordsController>();
  final _tooltip = TooltipBehavior(enable: true);
  late List<_ChartData> data;

  String _parse_time(String time) {
    DateTime dateTime = DateTime.parse(time);
    DateTime utcPlus8DateTime = dateTime.toUtc().add(Duration(hours: 8));
    String formattedDateTime = DateFormat('yyyy-MM-dd').format(utcPlus8DateTime);
    return formattedDateTime;
  }

  void initData(){
    data = [];
    switch(recordsC.method.value){
      case '全部':{
        Map<String,int?> temp = {};
        for (Record r in recordsC.records){
          String time = _parse_time(r.createTime);
          temp[time] = (temp[time] ?? 0) + 1;
        }
        temp.forEach((key, value) {
          data.add(_ChartData(key, value!));
        });
      }
      case '日期':{
        Map<String,int?> temp = {};
        if (recordsC.selected.value != '全部'){
          for (Record r in recordsC.records){
            String time = _parse_time(r.createTime);
            if (recordsC.selected.value == time){
              String username = Characters(r.attackFrom).length>7?'${Characters(r.attackFrom).take(7)}...':r.attackFrom;
              temp[username] = (temp[username] ?? 0) + 1;
            }
          }
        }else{
          for (Record r in recordsC.records){
            String time = _parse_time(r.createTime);
            temp[time] = (temp[time] ?? 0) + 1;
          }
        }
        temp.forEach((key, value) {
          data.add(_ChartData(key, value!));
        });
      }
      case '用户名':{
        Map<String,int?> temp = {};
        if (recordsC.selected.value != '全部'){
          for (Record r in recordsC.records){
            String time = _parse_time(r.createTime);
            if (recordsC.selected.value == r.attackFrom){
              temp[time] = (temp[time] ?? 0) + 1;
            }
          }
        }else{
          for (Record r in recordsC.records){
            String username = Characters(r.attackFrom).length>7?'${Characters(r.attackFrom).take(7)}...':r.attackFrom;
            temp[username] = (temp[username] ?? 0) + 1;
          }
        }

        temp.forEach((key, value) {
          data.add(_ChartData(key, value!));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
        child: SizedBox(
          // height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width, // 宽度为页面宽度的 80%
          child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                interval: 1,
                labelPlacement: LabelPlacement.betweenTicks,
              ),
              primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<_ChartData, String>>[
                BarSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    name: '出刀次数',
                    color: Color.fromRGBO(8, 142, 255, 1))
              ])
        )
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final int y;
}


class recordsController extends GetxController {
  RxString method = '全部'.obs;
  RxString selected = '全部'.obs;
  RxBool asc = false.obs;
  RxList<Record> records = <Record>[].obs;
  RxList<String> datetime = <String>[].obs;
}

