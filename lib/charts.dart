import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/youtube.dart';
import 'package:http/http.dart' as http;
import 'homescreen.dart';
import 'package:url_launcher/url_launcher.dart';  // Import this package to launch URLs

class Charts extends StatefulWidget {
  const Charts({Key? key}) : super(key: key);

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  int selectedButtonIndex = 0;
  List<dynamic> bsongs = [];

  @override
  void initState() {
    super.initState();
    getBsongs();
  }

  Future<void> getBsongs() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/KoreanThinker/billboard-json/main/billboard-hot-100/recent.json'));

    if (response.statusCode == 200) {
      setState(() {
        bsongs = jsonDecode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> refreshgetBsong() async {
    await getBsongs();
  }

  // Function to launch the YouTube URL
  Future<void> _launchYouTube(String songTitle) async {
    final String youtubeUrl = 'https://www.youtube.com/results?search_query=$songTitle';
    if (await canLaunch(youtubeUrl)) {
      await launch(youtubeUrl);
    } else {
      throw 'Could not open YouTube';
    }
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
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Youtube()));
                },
                child: Text(
                  'Youtube',
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
                  'Hot100',
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
            ],
          ),
          backgroundColor: Colors.black,
        ),
        body: RefreshIndicator(
          onRefresh: refreshgetBsong,
          color: Colors.orange[900],
          child: bsongs.isEmpty
              ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange[900],
              ))
              : ListView.builder(
            itemCount: bsongs.length,
            itemBuilder: (context, index) {
              final bsong = bsongs[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(1),
                    child: Card(
                      color: Colors.black,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${bsong['rank']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.orange[900]),
                              ),
                              Text(
                                '.',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 20),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (bsong['image'] != null)
                            Image.network(
                              bsong['image'],
                              scale: 2,
                            ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${bsong['name']}' ?? 'No name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                  maxLines: null,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  bsong['artist'] ?? 'No artist',
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.visible,
                                  maxLines: null,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Last weeks rank: '
                                          '${bsong['last_week_rank']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Peak rank: ' '${bsong['peak_rank']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Weeks on chart: '
                                          '${bsong['weeks_on_chart']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                                // IconButton(
                                //   onPressed: (){
                                //     _launchYouTube(bsong['name']);
                                //   },
                                //   icon: Icon(Icons.play_arrow, color: Colors.orange[900],),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Divider(
                      color: Colors.grey[400],
                      thickness: 2,
                      height: 15,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
