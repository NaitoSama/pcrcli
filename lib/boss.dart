import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcrcli/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class bossPage extends StatefulWidget {
  const bossPage({super.key});

  @override
  State<bossPage> createState() => _bossPageState();
}

class _bossPageState extends State<bossPage> {
  final TextEditingController _damage = TextEditingController();
  final TextEditingController _revise = TextEditingController();

  late WebSocketChannel ws;
  late String token;


  @override



  Future _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('url') ?? '';
    token = prefs.getString('token') ?? '';
    ws = IOWebSocketChannel.connect(
        '${url.replaceFirst('http', 'ws')}/v1/ws',
        headers: {
          HttpHeaders.cookieHeader:'pekoToken=$token'
        }
    );
    ws.stream.listen((event) {
      handleWebsocketMessage(event);
    });
    sendInitData();
  }

  void handleWebsocketMessage(dynamic message) {
    // todo 处理ws收到的数据，更新appState的boss信息并执行notifyListeners()
    final data = jsonDecode(message);
    print('message: $message');
    print('data: $data');
    if (data is List) {
      Map<String,dynamic> data1 = data[0];
      if (data1.containsKey('WhoIsIn')){
        for(Map<String,dynamic> i in data) {
          print('i: $i');
          BossInfo boss = BossInfo(
            bossID:i['ID'],
            stage:i['Stage'],
            round:i['Round'],
            valueC:i['Value'],
            valueD:i['ValueD'],
            attacking:i['WhoIsIn'],
            tree:(i['Tree'] as String).split('|'),
          );
        Provider.of<AppState>(context, listen: false).updateBoss(boss,boss.bossID);
        }
      }else if (data1.containsKey('BeforeBossStage')){
        List<String> records = [];
        for(Map<String,dynamic> i in data){
          records.add('${i['AttackFrom']}对boss${i['AttackTo']}造成了${i['Damage']}点伤害!');
        }
        Provider.of<AppState>(context, listen: false).initRecord(records);
      }
      

    }else if (data is Map){
      if(data.containsKey('WhoIsIn')){
        BossInfo boss = BossInfo(
          bossID:data['ID'],
          stage:data['Stage'],
          round:data['Round'],
          valueC:data['Value'],
          valueD:data['ValueD'],
          attacking:data['WhoIsIn'],
          tree:(data['Tree'] as String).split('|'),
        );
        Provider.of<AppState>(context, listen: false).updateBoss(boss,boss.bossID);
      }else if (data.containsKey('BeforeBossStage')){
        Provider.of<AppState>(context, listen: false).appendRecord('${data['AttackFrom']}对boss${data['AttackTo']}造成了${data['Damage']}点伤害!');
      }
    }
  }

  // ws发送一次获取boss状态的请求 需要已有ws和token
  void sendInitData(){
    Map<String,String> jsonData = {
      'type':'getBoss',
      'token':token,
    };

    String jsonString = jsonEncode(jsonData);
    ws.sink.add(jsonString);

    jsonData = {
      'type':'getRecord',
      'token':token,
    };
    jsonString = jsonEncode(jsonData);
    ws.sink.add(jsonString);
  }

  @override
  void dispose() {
    ws.sink.close();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F4F8),
        automaticallyImplyLeading: false,
        title: Text(
          'Clan Battle',
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),

      body: FutureBuilder(
        future: _loadPreferences(),
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError) {
              // 请求失败，显示错误
              print("Error: ${snapshot.error}");
            } else {
              // 请求成功，显示数据
              print("ok");
            }
          } else {
            // 请求未结束，显示loading
            return CircularProgressIndicator();
          }



          return ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 公告栏
              recordBoard(),
              // Boss 状态格子

              GestureDetector(
                  onTap: () => showDialog(

              context: context,
              builder: (BuildContext context) {
              return bossCMD(bossID: 1,);
              },
              ),
                  child: bossCard(bossID: 1,bossImg: 'images/1.jpg',)
              ),
              GestureDetector(
                  onTap: () => showDialog(

              context: context,
              builder: (BuildContext context) {
              return bossCMD(bossID: 2,);
              },
              ),
                  child: bossCard(bossID: 2,bossImg: 'images/2.jpg',)
              ),
              GestureDetector(
                  onTap: () => showDialog(

              context: context,
              builder: (BuildContext context) {
              return bossCMD(bossID: 3,);
              },
              ),
                  child: bossCard(bossID: 3,bossImg: 'images/3.jpg',)
              ),
              GestureDetector(
                  onTap: () => showDialog(

              context: context,
              builder: (BuildContext context) {
              return bossCMD(bossID: 4,);
              },
              ),
                  child: bossCard(bossID: 4,bossImg: 'images/4.jpg',)
              ),
              GestureDetector(
                  onTap: () => showDialog(

              context: context,
              builder: (BuildContext context) {
              return bossCMD(bossID: 5,);
              },
              ),
                  child: bossCard(bossID: 5,bossImg: 'images/5.jpg',)
              ),
              // GestureDetector(
              //     onTap: () => bossCMD(bossID: 2,),
              //     child: bossCard(bossName: 'Boss 2',bossImg: 'images/2.jpg',)
              // ),
              // GestureDetector(
              //     onTap: () => bossCMD(bossID: 3,),
              //     child: bossCard(bossName: 'Boss 3',bossImg: 'images/3.jpg',)
              // ),
              // GestureDetector(
              //     onTap: () => bossCMD(bossID: 4,),
              //     child: bossCard(bossName: 'Boss 4',bossImg: 'images/4.jpg',)
              // ),
              // GestureDetector(
              //     onTap: () => bossCMD(bossID: 5,),
              //     child: bossCard(bossName: 'Boss 5',bossImg: 'images/5.jpg',)
              // ),
              // ElevatedButton(onPressed: (){_addRecord('test');_recordToBottom();}, child: Text('add test to records')),
              // ElevatedButton(onPressed: (){
              //   var boss1 = appState.boss1;
              //   boss1.bossID += 1;
              //   appState.updateBoss(boss1,1);
              // }, child: Text('boss test'))
              ElevatedButton(
                  onPressed: (){
                    Provider.of<AppState>(context, listen: false).appendRecord('test');
                  },
                  child: Text('add record board test')
              )
            ],
          );
        }
      ),
    );
  }
}

class BossStatusTile extends StatelessWidget {
  final String bossName;

  const BossStatusTile({super.key, required this.bossName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            bossName,
            style: TextStyle(fontSize: 18.0),
          ),
          Icon(Icons.star, color: Colors.orange),
        ],
      ),
    );
  }
}

class bossCard extends StatefulWidget {
  final int bossID;
  final String bossImg;
  const bossCard({super.key, required this.bossID, required this.bossImg});

  @override
  State<bossCard> createState() => _bossCardState();
}

class _bossCardState extends State<bossCard> {
  late int bossID;
  late BossInfo boss;
  late String bossImg;
  late dynamic appState;
  @override
  void initState() {
    super.initState();
    bossID = widget.bossID;
    bossImg = widget.bossImg;
  }
  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    switch (bossID){
      case 1: boss = appState.boss1;break;
      case 2: boss = appState.boss2;break;
      case 3: boss = appState.boss3;break;
      case 4: boss = appState.boss4;break;
      case 5: boss = appState.boss5;break;
    }
    return // Generated code for this Container Widget...
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x520E151B),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    bossImg,
                    width: 80,
                    height: 80,
                    // fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: boss.valueC/boss.valueD,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('${boss.stage}阶 ${boss.round}回'),
                                  Text('${NumberFormat('#,##0').format(boss.valueC)}/${NumberFormat('#,##0').format(boss.valueD)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('攻击:${boss.attacking}'),
                                  Text('挂树:${boss.tree[0]==' '?0:boss.tree.length}'),
                                ],
                              )
                            ]
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
      );

  }
}

class bossCMD extends StatefulWidget {
  final int bossID;
  const bossCMD({super.key, required this.bossID});

  @override
  State<bossCMD> createState() => _bossCMDState();
}

class _bossCMDState extends State<bossCMD> {
  late int bossID;
  final TextEditingController _damage = TextEditingController();
  final TextEditingController _revise = TextEditingController();
  @override
  void initState() {
    super.initState();
    bossID = widget.bossID;
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        constraints: BoxConstraints(
          maxWidth: 200.0, // 设置最大宽度
        ),
        child: Text('111'),
      )
    );
  }
}


class recordBoard extends StatefulWidget {
  const recordBoard({super.key});

  @override
  State<recordBoard> createState() => _recordBoardState();
}

class _recordBoardState extends State<recordBoard> {
  final List<String> records = [];
  final ScrollController _recordCtl = ScrollController();
  late dynamic appState;

  // List<Widget> _buildRecords(){
  //   return appState.records;
  // }

  // void _addRecord(String value){
  //   setState(() {
  //     records.add(value);
  //   });
  // }

  void didChangeDependencies(){
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _recordToBottom();
    });
  }

  void _recordToBottom(){
    _recordCtl.animateTo(
      _recordCtl.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.8,
        height: MediaQuery.sizeOf(context).height * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x520E151B),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
            padding: EdgeInsetsDirectional.fromSTEB(10, 30, 10, 30),
            scrollDirection: Axis.vertical,
            controller: _recordCtl,
            itemCount: appState.records.length,
            itemBuilder: (BuildContext context, int index){
              return Center(child: Text(appState.records[index]));
            }
        ),
        // child: ListView(
        //   padding: EdgeInsetsDirectional.fromSTEB(10, 30, 10, 30),
        //   scrollDirection: Axis.vertical,
        //   controller: _recordCtl,
        //   children: _buildRecords(),
        // ),
      ),
    );
  }
}



