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
        'https://corsproxy.io/?https://api.deezer.com/artist/1/top?limit=200'));

    if (response.statusCode == 200) {
      final jsonresponse = jsonDecode(response.body);
      final results = jsonresponse['data'];

      setState(() {
        tracks = results;
        filteredItems = results;
      });
    } else {
      throw Exception('Failed to load files.');
    }
  }

  void filterItems() {
    setState(() {
      filteredItems = tracks
          .where((track) => track['title']
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

  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
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

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              track['album']?['cover_medium'] ?? '',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track['title'] ?? 'No title',
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Duration: ${formatDuration(track['duration'])}',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  'Position: ${index + 1}',
                                  style: TextStyle(color: Colors.white54, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Music(
                                    tracks: tracks,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.play_circle_fill,
                              color: Colors.orange[900],
                              size: 32,
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

