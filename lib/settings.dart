import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 0)
class AppSettings {
  @HiveField(0)
  Map<String,int> getIndex = {};
  @HiveField(1)
  bool isDarkMode = false;
  @HiveField(2)
  bool isUrlConfirmed = false;
  @HiveField(3)
  bool isLoggedIn = false;
  @HiveField(4)
  String remoteServerUrl = '';
  @HiveField(5)
  String username = '';
  @HiveField(6)
  int authority = 0;
  @HiveField(7)
  String token = '';

  void initIndex(){
    for(int i = 1;i<=7;i++){
      switch (i){
      case 1:getIndex['isDarkMode'] = 1;break;
      case 2:getIndex['isUrlConfirmed'] = 2;break;
      case 3:getIndex['isLoggedIn'] = 3;break;
      case 4:getIndex['remoteServerUrl'] = 4;break;
      case 5:getIndex['username'] = 5;break;
      case 6:getIndex['authority'] = 6;break;
      case 7:getIndex['token'] = 7;break;
      }
    }
  }
}