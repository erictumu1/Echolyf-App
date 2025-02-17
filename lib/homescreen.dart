import 'package:flutter/material.dart';
import 'package:flutter_application_1/charts.dart';
import 'package:flutter_application_1/music.dart';
import 'package:flutter_application_1/youtube.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'search.dart';
import 'files.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
  int? selectedbuttonindex;
  int? selectedbutton_dummy;
  late AnimationController controller;
  List<dynamic> articles = [];
  List<dynamic> albums = [];
  List<dynamic> tracks = [];

  void pressedbutton(int index) {
    setState(() {
      if (selectedbuttonindex != index) {
        selectedbuttonindex = index;
      } else {
        selectedbuttonindex = selectedbutton_dummy;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..repeat();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=b0b0bf7ec0384190a044541bf1265050'));

    final response1 = await http.get(Uri.parse(
        'https://api.jamendo.com/v3.0/albums/tracks/?client_id=8d3f4a22&format=jsonpretty&limit=1&artist_name=we+are+fm'));

    if (response.statusCode == 200) {
      setState(() {
        articles = jsonDecode(response.body)['articles'];
        final jsonresponse = jsonDecode(response1.body);
        final results = jsonresponse['results'];
        final List<dynamic> loadedtracks = [];
        albums = results;

        for (var album in results) {
          if (album['tracks'] != null) {
            loadedtracks.addAll(album['tracks']);
          }
        }
        setState(() {
          tracks = loadedtracks;
        });
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> refreshdata() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Home',
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
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Charts()));
                },
                child: Text(
                  ' Hot100',
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
        ),
        body: RefreshIndicator(
          onRefresh: refreshdata,
          color: Colors.orange[900],
          child: articles.isEmpty
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.orange[900],
            ),
          )
              : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];

                // Check if the image URL is not null
                if (article['urlToImage'] == null) {
                  return Container();  // Skip rendering this article if no image
                }

                return Card(
                  margin: EdgeInsets.all(1),
                  color: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              if (article['title'] != null)
                                ...() {
                                  String title = article['title'];
                                  int lastHyphenIndex = title.lastIndexOf('-');
                                  if (lastHyphenIndex != -1) {
                                    return [
                                      TextSpan(
                                        text: title.substring(0, lastHyphenIndex).trim(),
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' - ', // Keeping the last hyphen as part of formatting
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: title.substring(lastHyphenIndex + 1).trim(),
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[900],
                                        ),
                                      ),
                                    ];
                                  } else {
                                    return [
                                      TextSpan(
                                        text: title.trim(),
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ];
                                  }
                                }()
                            ],
                          ),
                        ),
                      ),
                      Image.network(article['urlToImage']),
                      SizedBox(
                        height: 10,
                      ),// Image will only be rendered if it exists
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          article['description'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          article['publishedAt'] ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Divider(  // Add this Divider after each card
                          color: Colors.grey[400],  // Set the line color to match the theme
                          thickness: 2,  // Line thickness
                          height: 5,  // Space between the divider and the next item
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              label: 'Files',
              icon: Container(
                height: 40,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Files()));
                  },
                  child: Icon(
                    Icons.folder_copy,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 40,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Music(tracks: tracks, initialIndex: 0)));
                  },
                  child: Icon(
                    Icons.headset,
                    color: Colors.orange[900],
                    size: 50,
                  ),
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              label: 'Search',
              icon: Container(
                height: 40,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Search()));
                  },
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          onTap: pressedbutton,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
