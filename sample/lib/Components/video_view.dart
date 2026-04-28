import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final bool needMutedButton;

  const VideoView({
    super.key,
    this.needMutedButton = false,
  });

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _controller;
  bool _isMuted = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/Meet_Computer_by_DevRev_1080P.mp4')
          ..initialize().then((_) {
            setState(() {
              _isInitialized = true;
            });
            _controller.setVolume(_isMuted ? 0.0 : 1.0);
            _controller.setLooping(true);
            _controller.play();
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: Text("Video not found / loading..."));
    }

    return Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        if (widget.needMutedButton)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isMuted = !_isMuted;
                    _controller.setVolume(_isMuted ? 0.0 : 1.0);
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
