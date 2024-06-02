import 'package:flutter/material.dart';
import 'package:flutter_application_1/music.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with TickerProviderStateMixin {
  List<dynamic> tracks = [];
  List<dynamic> albums = [];
  List<dynamic> filteredItems = [];

  TextEditingController searchController = TextEditingController();
  FocusNode seacrhfocusnode = FocusNode();

  @override
  void initState() {
    super.initState();
    getSongFiles();
    searchController.addListener(filterItems);
  }

  Future<void> getSongFiles() async {
    final response = await http.get(Uri.parse(
        'https://api.jamendo.com/v3.0/albums/tracks/?client_id=8d3f4a22&format=jsonpretty&limit=1&artist_name=we+are+fm'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final results = jsonResponse['results'];
      final List<dynamic> loadedTracks = [];
      albums = results;

      for (var album in results) {
        if (album['tracks'] != null) {
          loadedTracks.addAll(album['tracks']);
        }
      }
      setState(() {
        tracks = loadedTracks;
        filteredItems = loadedTracks;
      });
    } else {
      throw Exception('Failed to load files.');
    }
  }

  void filterItems() {
    setState(() {
      filteredItems = tracks
          .where((track) => track['name']
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterItems);
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshPage() async {
    await getSongFiles();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: BackButton(
            color: Colors.orange[900],
          ),
          backgroundColor: Colors.black,
          title: Text(
            'Search',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
              fontSize: 25,
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  focusNode: seacrhfocusnode,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    filled: true,
                    fillColor: Colors.black12,
                    labelStyle: TextStyle(
                      color: seacrhfocusnode.hasFocus
                          ? Colors.orange[900]
                          : Colors.white,
                    ),
                  ),
                  style: TextStyle(color: Colors.orange[900]),
                ),
              ),
              Expanded(
                child: tracks.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.orange[900],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final track = filteredItems[index];
                          final album = albums[0];
                          return Card(
                            color: Colors.black,
                            child: Row(
                              children: [
                                if (album['image'] != null)
                                  Image.network(
                                    album['image'],
                                    scale: 2,
                                  ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track['name'] ?? 'No name',
                                        style: TextStyle(
                                            color: Colors.orange[900],
                                            fontSize: 20),
                                      ),
                                      if (track['audio'] != null)
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Music(
                                                        tracks: tracks,
                                                        initialIndex: index)));
                                          },
                                          icon: Icon(
                                            Icons.play_arrow_sharp,
                                            color: Colors.orange[900],
                                            size: 25,
                                          ),
                                        ),
                                      if (track['duration'] is String)
                                        Text(
                                          'Duration: '
                                          '${formatDuration(Duration(seconds: int.parse(track['duration'])))}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      // If the duration is already a Duration object, use it directly
                                      if (track['duration'] is Duration)
                                        Text(
                                          formatDuration(track['duration']),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      Text(
                                        'Position: ${track['position']}',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
