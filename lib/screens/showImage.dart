import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class ShowImage extends StatefulWidget {
  final int type;
  final String url;

  ShowImage({this.type, this.url});
  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    runVideo();
  }

  void runVideo() async {
    if (widget.type == 1) {
      _controller = await VideoPlayerController.network(widget.url)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        }).then((value) {
          if (_controller != null && _controller.value.initialized) {
            _controller.play();
          }
        });
    }
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(
          backgroundColor: Colors.black,
          title: new Text(
            widget.type == 0 ? 'Photo' : 'Video',
            style: GoogleFonts.comfortaa(color: Colors.white),
          ),
          centerTitle: true,
          leading: new IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          elevation: 0,
        ),
        floatingActionButton: widget.type == 0
            ? Container(
                height: 0.1,
                width: 0.1,
              )
            : FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller != null && _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
        body: widget.type == 1
            ? Center(
                child: videoControllerWidget(),
              )
            : Center(
                child: new CachedNetworkImage(
                  imageUrl: widget.url,
                  progressIndicatorBuilder: (context, url, progress) =>
                      CircularProgressIndicator(
                    value: progress.progress,
                  ),
                ),
              ));
  }

  Widget videoControllerWidget() {
    return _controller != null && _controller.value.initialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
