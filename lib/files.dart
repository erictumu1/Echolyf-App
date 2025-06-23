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
        'https://corsproxy.io/?https://api.deezer.com/artist/1/top?limit=200')); // Fetch top 200 tracks

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> loadedTracks = jsonResponse['data'];

      setState(() {
        tracks = loadedTracks;
        albums = loadedTracks.map((track) => track['album']).toList();
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
          leading: BackButton(color: Colors.orange[900]),
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
            child: CircularProgressIndicator(color: Colors.orange[900]),
          )
              : ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final album = albums[index]; // Get corresponding album
              final albumCover = album['cover_medium'] ?? '';
              final duration = formatDuration(Duration(seconds: track['duration']));

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
                      child: albumCover.isNotEmpty
                          ? Image.network(
                        albumCover,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.music_note,
                        color: Colors.orange[900],
                        size: 80,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track['title_short'] ?? 'No title',
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
                            'Duration: $duration',
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
                      icon: Icon(
                        Icons.play_circle_fill,
                        color: Colors.orange[900],
                        size: 32,
                      ),
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
