import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StartUp extends StatefulWidget {
  const StartUp({super.key});

  @override
  State<StartUp> createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> {
  final ipAdd = TextEditingController();
  final port = TextEditingController();
  String? getUrl(String ip,String port){
    if ( ip=='' || port=='' ){
      return '';
    }
    else{
      return ip+':'+port;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(50, 50, 50, 35),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.6,
                    height: MediaQuery.sizeOf(context).height * 0.28,
                    decoration: const BoxDecoration(
                      // color: Colors.blue,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'images/64135784.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
              ),
              Container(
                width: MediaQuery.sizeOf(context).width * 0.8,
                height: MediaQuery.sizeOf(context).height * 0.3,
                decoration: const BoxDecoration(
                  // color: Colors.blue,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextFormField(
                      controller: ipAdd,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: 'IP Address',
                        hintText: 'Enter IP address...',
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF59BCF8),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                      ),
                    ),
                    // Container(
                    //   height: 20,
                    // ),
                    TextFormField(
                      controller: port,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: 'Port',
                        hintText: 'Enter Port...',
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF59BCF8),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                      ),
                    ),
                    // Container(
                    //   height: 20,
                    // ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.6,
                      height: MediaQuery.sizeOf(context).height * 0.1,
                      decoration: const BoxDecoration(
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                        child: TextButton(
                          style: ButtonStyle(
                            // backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                            // foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                            side: MaterialStateProperty.all<BorderSide>(
                              const BorderSide(color: Color(0xFF59BCF8), width: 2),
                            ),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),

                          onPressed: () {
                            // 按钮被点击时执行的操作
                            String address = ipAdd.text + ':' + port.text;
                            print(getUrl(ipAdd.text,port.text));
                          },

                          child: const Text(
                            'Commit',
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              color: Color(0xFF59BCF8),
                              fontSize: 14,
                            ),
                          ),
                      ),
                    )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
