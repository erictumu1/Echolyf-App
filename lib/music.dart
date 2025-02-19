import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'dart:convert';

class Music extends StatefulWidget {
  final List<dynamic> tracks;
  final int initialIndex;

  const Music({Key? key, required this.tracks, required this.initialIndex})
      : super(key: key);

  @override
  State<Music> createState() => _MusicState();
}

// Playback modes
enum PlaybackMode { normal, repeat, shuffle }
PlaybackMode playbackMode = PlaybackMode.normal;

class _MusicState extends State<Music> with TickerProviderStateMixin {
  List<dynamic> tracks = [];
  Map<String, dynamic> album = {};
  int previousTrackIndex = -1;
  final ScrollController _scrollController = ScrollController();


  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int currentTrackIndex = 0;

  @override
  void initState() {
    super.initState();
    tracks = widget.tracks;
    currentTrackIndex = widget.initialIndex;
    playTrack(currentTrackIndex,0);

    audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });

    audioPlayer.durationStream.listen((newDuration) {
      setState(() {
        duration = newDuration ?? Duration.zero;
      });
    });

    audioPlayer.positionStream.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    getsongfiles();
  }

  void previousTrack() {
    if (previousTrackIndex >= 0) {
      playTrack(previousTrackIndex, 1);  // Go back to the previous track
    }
  }

  Future<void> playTrack(int index, int play) async {
    // Store the current track as the previous track before changing
    if (currentTrackIndex != index) {
      previousTrackIndex = currentTrackIndex;
    }

    final track = tracks[index];
    if (track['audio'] != null) {
      try {
        await audioPlayer.setUrl(track['audio']);
        if (play == 1) {
          await audioPlayer.play();
        }
        setState(() {
          currentTrackIndex = index;
        });

        // Scroll to the current track when it starts playing
        _scrollController.animateTo(
          index * 60.0,  // Multiply by an arbitrary height for each row (60.0 is just an example, adjust based on your design)
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

      } catch (e) {
        print('Error playing audio: $e');
      }
    }
  }



  void nextTrack() {
    if (playbackMode == PlaybackMode.shuffle) {
      int newIndex;
      do {
        newIndex = Random().nextInt(tracks.length);
      } while (newIndex == currentTrackIndex);
      playTrack(newIndex, 1);
    } else if (playbackMode == PlaybackMode.repeat) {
      // Repeat the current track once, then move to next
      playTrack(currentTrackIndex, 0);  // Play current track again (no immediate play)
      Future.delayed(Duration(seconds: duration.inSeconds), () {
        if (currentTrackIndex < tracks.length - 1) {
          playTrack(currentTrackIndex + 1, 1);  // After the current track ends, go to the next one
        }
      });
    } else {
      if (currentTrackIndex < tracks.length - 1) {
        playTrack(currentTrackIndex + 1, 1);  // Normal mode, go to the next track
      }
    }
  }

  void togglePlaybackMode() {
    setState(() {
      if (playbackMode == PlaybackMode.normal) {
        playbackMode = PlaybackMode.repeat;
      } else if (playbackMode == PlaybackMode.repeat) {
        playbackMode = PlaybackMode.shuffle;
      } else {
        playbackMode = PlaybackMode.normal;
      }
    });
  }


  Future<void> getsongfiles() async {
    final response = await http.get(Uri.parse(
        'https://api.jamendo.com/v3.0/albums/tracks/?client_id=8d3f4a22&format=jsonpretty&limit=1&artist_name=we+are+fm'));

    if (response.statusCode == 200) {
      final jsonresponse = jsonDecode(response.body);
      final results = jsonresponse['results'];

      album = results[0];

      final List<dynamic> loadedtracks = [];
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

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData getPlaybackIcon() {
    switch (playbackMode) {
      case PlaybackMode.repeat:
        return Icons.repeat_one;
      case PlaybackMode.shuffle:
        return Icons.shuffle;
      default:
        return Icons.repeat;
    }
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
            'Music',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
              fontSize: 25,
            ),
          ),
        ),
        body: tracks.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.orange[900],
                ),
              )
            : Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  if (album['image'] != null)
                    Image.network(
                      album['image'],
                      // scale: 2,
                    ),
                  // Display player controls and song progress
                  if (tracks.isNotEmpty)
                    Expanded(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (isPlaying) {
                                    await audioPlayer.pause();
                                  } else {
                                    await audioPlayer.play();
                                  }
                                },
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.orange[900],
                                  size: 40,
                                ),
                              ),
                              Slider(
                                activeColor: Colors.orange[900],
                                inactiveColor: Colors.white,
                                min: 0,
                                max: duration.inSeconds.toDouble(),
                                value: position.inSeconds.toDouble(),
                                onChanged: (value) async {
                                  final position =
                                      Duration(seconds: value.toInt());
                                  await audioPlayer.seek(position);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatDuration(position),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      formatDuration(duration - position),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () => previousTrack(),
                                    icon: Icon(
                                      Icons.skip_previous,
                                      color: currentTrackIndex > 0
                                          ? Colors.orange[900]
                                          : Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => togglePlaybackMode(),
                                    icon: Icon(
                                      getPlaybackIcon(),
                                      color: Colors.grey[400],
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => nextTrack(),
                                    icon: Icon(
                                      Icons.skip_next,
                                      color: currentTrackIndex < tracks.length - 1
                                          ? Colors.orange[900]
                                          : Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Display the list of songs in cards with album image on the left
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,  // Add the controller here
                              itemCount: tracks.length,
                              itemBuilder: (context, index) {
                                final track = tracks[index];
                                final albums = album[0];
                                return Card(
                                  color: currentTrackIndex == index
                                      ? Colors.orange[900]
                                      : Colors.black,
                                  child: ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(album['image'] ?? ''),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      track['name'] ?? 'No name',
                                      style: TextStyle(
                                        color: currentTrackIndex == index
                                            ? Colors.white
                                            : Colors.white,
                                      ),
                                    ),
                                    onTap: () => playTrack(index, 1),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
