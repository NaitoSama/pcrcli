import 'package:flutter/material.dart';

class bossPage extends StatefulWidget {
  const bossPage({super.key});

  @override
  State<bossPage> createState() => _bossPageState();
}

class _bossPageState extends State<bossPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主页面'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 公告栏
          Container(
            color: Colors.blue,
            padding: EdgeInsets.all(16.0),
            child: Text(
              '最新公告: Flutter 主页面示例',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // Boss 状态格子
          BossStatusTile(bossName: 'Boss 1'),
          BossStatusTile(bossName: 'Boss 2'),
          BossStatusTile(bossName: 'Boss 3'),
          BossStatusTile(bossName: 'Boss 4'),
          BossStatusTile(bossName: 'Boss 5'),
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
