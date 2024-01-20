import 'package:flutter/material.dart';

class bossPage extends StatefulWidget {
  const bossPage({super.key});

  @override
  State<bossPage> createState() => _bossPageState();
}

class _bossPageState extends State<bossPage> {
  final TextEditingController _damage = TextEditingController();
  final TextEditingController _revise = TextEditingController();



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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 公告栏
          // Container(
          //   color: Colors.blue,
          //   padding: EdgeInsets.all(16.0),
          //   child: Text(
          //     '最新公告: Flutter 主页面示例',
          //     style: TextStyle(color: Colors.white),
          //   ),
          // ),
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
                padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                scrollDirection: Axis.vertical,
                children: [
                  Text('123321'),
                  Text('1234567'),
                  Text('123321'),
                  Text('1234567'),
                  Text('123321'),
                  Text('1234567'),
                  Text('123321'),
                  Text('1234567'),
                  Text('123321'),
                  Text('1234567'),
                  Text('123321'),
                  Text('1234567'),
                ],
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
              child: bossCard(bossName: 'Boss 1',bossImg: 'images/1.webp',)
          ),
          GestureDetector(
              onTap: () => bossCMD(bossID: 2,),
              child: bossCard(bossName: 'Boss 2',bossImg: 'images/2.webp',)
          ),
          GestureDetector(
              onTap: () => bossCMD(bossID: 3,),
              child: bossCard(bossName: 'Boss 3',bossImg: 'images/3.webp',)
          ),
          GestureDetector(
              onTap: () => bossCMD(bossID: 4,),
              child: bossCard(bossName: 'Boss 4',bossImg: 'images/4.webp',)
          ),
          GestureDetector(
              onTap: () => bossCMD(bossID: 5,),
              child: bossCard(bossName: 'Boss 5',bossImg: 'images/5.webp',)
          ),
        ],
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
  final String bossName;
  final String bossImg;
  const bossCard({super.key, required this.bossName, required this.bossImg});

  @override
  State<bossCard> createState() => _bossCardState();
}

class _bossCardState extends State<bossCard> {
  late String bossName;
  late String bossImg;
  @override
  void initState() {
    super.initState();
    bossName = widget.bossName;
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
                            bossName,
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


