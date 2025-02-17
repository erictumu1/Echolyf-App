import 'package:flutter/material.dart';
import 'package:flutter_application_1/homescreen.dart';
import 'package:flutter_application_1/charts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Youtube extends StatefulWidget {
  const Youtube({super.key});

  @override
  State<Youtube> createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  late final WebViewController controller;
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isloading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isloading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.youtube.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Homescreen()));
                  },
                  child: Text(
                    'Home',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStatePropertyAll(10),
                    backgroundColor: MaterialStatePropertyAll(Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Youtube',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                      fontSize: 18,
                    ),
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStatePropertyAll(10),
                    backgroundColor: MaterialStatePropertyAll(Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => Charts()));
                  },
                  child: Text(
                    'Hot100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStatePropertyAll(10),
                    backgroundColor: MaterialStatePropertyAll(Colors.black),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black,
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: controller),
              if (isloading) // Show loader only if isloading is true
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange[900],
                  ),
                ),
            ],
          ),
        ));
  }
}
