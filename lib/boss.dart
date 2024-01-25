import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
  final List<String> records = [];
  final ScrollController _recordCtl = ScrollController();
  late WebSocketChannel ws;
  late String token;
  late dynamic appState;


  @override
  List<Widget> _buildRecords(){
    return records.map((e) => Center(child: Text(e))).toList();
  }

  void _addRecord(String value){
    setState(() {
      records.add(value);
    });
  }

  void _recordToBottom(){
    _recordCtl.animateTo(
        _recordCtl.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
    );
  }

  Future<Map<String,String>> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('url') ?? '';
    String token = prefs.getString('token') ?? '';
    return {'url':url,'token':token};
  }

  void handleWebsocketMessage(dynamic message) {
    // todo 处理ws收到的数据，更新appState的boss信息并执行notifyListeners()
  }

  // ws发送一次获取boss状态的请求 需要已有ws和token
  void sendInitData(){
    Map<String,String> jsonData = {
      'type':'getBoss',
      'token':token,
    };

    String jsonString = jsonEncode(jsonData);
    ws.sink.add(jsonString);
  }

  @override
  void dispose() {
    ws.sink.close();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
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
            token = snapshot.data!['token']!;
            ws = IOWebSocketChannel.connect(
              '${snapshot.data?['url']?.replaceFirst('http', 'ws')}/v1/ws',
              headers: {
                HttpHeaders.cookieHeader:'pekoToken=${snapshot.data?['token']}'
              }
            );
            ws.stream.listen((event) {
              handleWebsocketMessage(event);
            });
            sendInitData();

          }



          return ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 公告栏
              Padding(
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
                  child: ListView(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 30, 10, 30),
                    scrollDirection: Axis.vertical,
                    controller: _recordCtl,
                    children: _buildRecords(),
                  ),
                ),
              ),
              // Boss 状态格子

              GestureDetector(
                  onTap: () => showDialog(

              context: context,
              builder: (BuildContext context) {
              return bossCMD(bossID: 1,);
              },
              ),
                  child: bossCard(boss:appState.boss1,bossImg: 'images/1.jpg',)
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
              ElevatedButton(onPressed: (){_addRecord('test');_recordToBottom();}, child: Text('add test to records')),
              ElevatedButton(onPressed: (){
                var boss1 = appState.boss1;
                boss1.bossID += 1;
                appState.updateBoss(boss1,1);
              }, child: Text('boss test'))

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
  final BossInfo boss;
  final String bossImg;
  const bossCard({super.key, required this.boss, required this.bossImg});

  @override
  State<bossCard> createState() => _bossCardState();
}

class _bossCardState extends State<bossCard> {
  late BossInfo boss;
  late String bossImg;
  @override
  void initState() {
    super.initState();
    boss = widget.boss;
    bossImg = widget.bossImg;
  }
  @override
  Widget build(BuildContext context) {
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
                          value: 0.5,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                          child: Text(
                            '${boss.bossID}',
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


