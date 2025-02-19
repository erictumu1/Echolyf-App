import 'package:flutter/material.dart';
import 'package:flutter_application_1/music.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Files extends StatefulWidget {
  const Files({super.key});

  @override
  State<Files> createState() => _FilesState();
}

class _FilesState extends State<Files> with TickerProviderStateMixin {
  List<dynamic> tracks = [];
  List<dynamic> albums = [];

  @override
  void initState() {
    super.initState();
    getsongfiles();
  }

  Future<void> getsongfiles() async {
    final response = await http.get(Uri.parse(
        'https://api.jamendo.com/v3.0/albums/tracks/?client_id=8d3f4a22&format=jsonpretty&limit=1&artist_name=we+are+fm'));

    if (response.statusCode == 200) {
      final jsonresponse = jsonDecode(response.body);
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
    } else {
      throw Exception('Failed to load files.');
    }
  }

  Future<void> refreshpage() async {
    await getsongfiles();
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
            'Files',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
              fontSize: 25,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: refreshpage,
          color: Colors.orange[900],
          child: tracks.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange[900],
                  ),
                )
              : ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track['name'] ?? 'No name',
                                  style: TextStyle(
                                      color: Colors.orange[900], fontSize: 20),
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
                                // Check if the duration is a String and parse it to Duration
                                if (track['duration'] is String)
                                  Text(
                                    'Duration: '
                                    '${formatDuration(Duration(seconds: int.parse(track['duration'])))}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                // If the duration is already a Duration object, use it directly
                                if (track['duration'] is Duration)
                                  Text(
                                    formatDuration(track['duration']),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                Text(
                                  'position: ' '${track['position']}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Divider(
                                    color: Colors.grey[400],
                                    thickness: 2,
                                    height: 15,
                                  ),
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
      ),
    );
  }
}
