import 'package:flutter/material.dart';

class bossPage extends StatefulWidget {
  const bossPage({super.key});

  @override
  State<bossPage> createState() => _bossPageState();
}

class _bossPageState extends State<bossPage> {

  Future<void> bossCMD(int bossID){
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.76,
                    height: MediaQuery.sizeOf(context).height * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x520E151B),
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      children: [],
                    ),
                  ),
                );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('主页面'),
      // ),
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
            padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
            child: ListView(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    height: MediaQuery.sizeOf(context).height * 0.3,
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
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      children: [],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Boss 状态格子
          GestureDetector(
              onTap: () => bossCMD(1),
              child: bossCard(bossName: 'Boss 1',bossImg: 'images/1.webp',)
          ),
          GestureDetector(
              onTap: () => bossCMD(2),
              child: bossCard(bossName: 'Boss 2',bossImg: 'images/2.webp',)
          ),
          GestureDetector(
              onTap: () => bossCMD(3),
              child: bossCard(bossName: 'Boss 3',bossImg: 'images/3.webp',)
          ),
          GestureDetector(
              onTap: () => bossCMD(4),
              child: bossCard(bossName: 'Boss 4',bossImg: 'images/4.webp',)
          ),
          GestureDetector(
              onTap: () => bossCMD(5),
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


