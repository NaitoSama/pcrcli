part of 'boss.dart';

class bossLPCMDDialog extends AlertDialog {
  const bossLPCMDDialog({super.key, required Widget contentWidget})
      : super(
          content: contentWidget,
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(20),
          //   side: BorderSide(color: Colors.blue, width: 3),
          // ),
        );
}

class bossLPCMD extends StatelessWidget {
  final int bossID;
  var getx = Get.find<GetxSettings>();
  var homeData = Get.find<HomeData>();

  bossLPCMD(this.bossID, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x520E151B),
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: ElevatedButton(
            onPressed: () {
              notification.sendANotify('test', 1, '2', 'test');
            },
            child: Text('1')),
      ),
    );
  }
}
