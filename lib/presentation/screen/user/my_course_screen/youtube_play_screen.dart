import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms/core/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;

  const YoutubePlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final id = YoutubePlayer.convertUrlToId(widget.videoId) ?? widget.videoId;

    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: AppColor.primaryBlueMid,
          handleColor: AppColor.primaryBlueLight,
          bufferedColor: Colors.grey,
          backgroundColor: Colors.black26,
        ),
        onReady: () {
          debugPrint("Ready");
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,

          appBar:
              isLandscape
                  ? null
                  : AppBar(
                    title: Text(widget.title),
                    centerTitle: true,
                    elevation: 0,
                  ),

          body: SafeArea(
            child:
                isLandscape
                    ? Center(child: player)
                    : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: player,
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: const [
                                  Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Recorded Lecture",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              const Text(
                                "Lesson Description",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "This lesson explains the concepts in detail. "
                                "Watch the entire video before proceeding to the next module.",
                                style: TextStyle(
                                  height: 1.6,
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 30),

                              FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.check_circle),
                                label: const Text("Mark as Completed"),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  backgroundColor: AppColor.primaryBlueMid,
                                ),
                              ),

                              const SizedBox(height: 20),
                            ]),
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
