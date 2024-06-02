import 'package:flutter/material.dart';
import 'package:flutter_application_1/homescreen.dart';

class Startscreen extends StatefulWidget {
  const Startscreen({super.key});

  @override
  State<Startscreen> createState() => _StartscreenState();
}

class _StartscreenState extends State<Startscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Homescreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
            ),
            backgroundColor: Colors.black,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.headset,
                            size: 180,
                            color: Colors.orange[900],
                          ),
                          Column(
                            children: [
                          Text(
                            'EchoLyf',
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'myfonts',
                              color: Colors.orange[900],
                            ),
                          ),
                          Text(
                            '"Simply the best"',
                            style: TextStyle(
                                fontFamily: 'Sacramento',
                                fontSize: 40,
                                color: Colors.white),
                          ),
                              ],
                          ),
                        ]),
                  ),
                );
  }
}
