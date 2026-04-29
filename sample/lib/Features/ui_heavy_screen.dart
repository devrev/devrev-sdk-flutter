import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../Components/video_view.dart';

class HeavyUIView extends StatefulWidget {
  const HeavyUIView({super.key});

  @override
  State<HeavyUIView> createState() => _HeavyUIViewState();
}

class _HeavyUIViewState extends State<HeavyUIView> {
  bool animationFinished = false;

  @override
  Widget build(BuildContext context) {
    if (!animationFinished) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/be_bold_animation.json',
                repeat: false,
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    if (mounted && !animationFinished) {
                      setState(() {
                        animationFinished = true;
                      });
                    }
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    animationFinished = true;
                  });
                },
                child: const Text(
                  "Next →",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 60),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const DevRevLogo(),
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: LottieAssetViewer(
                        assetPath: 'assets/animations/say_hi.json'),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 226,
                      child: VideoView(needMutedButton: true),
                    ),
                    NestedScrollViews(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NestedScrollViews extends StatelessWidget {
  const NestedScrollViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Animations:"),
          SizedBox(
            height: 320,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...lottieAnimationAssets.map((columnAssets) {
                  return Container(
                    width: 170,
                    padding: const EdgeInsets.only(right: 20),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: columnAssets.map((assetPath) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: RoundedShadowContainer(
                            width: 150,
                            height: 150,
                            child: LottieAssetViewer(assetPath: assetPath),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
                const RoundedShadowContainer(
                  width: 300,
                  height: 320,
                  child:
                      LottieAssetViewer(assetPath: MediaItems.lottieEmptyAsset),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: "Images:"),
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MediaItems.images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final assetPath = MediaItems.images[index];
                return RoundedShadowContainer(
                  width: 300,
                  height: 300,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedShadowContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const RoundedShadowContainer({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class LottieAssetViewer extends StatelessWidget {
  final String assetPath;
  const LottieAssetViewer({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      fit: BoxFit.contain,
    );
  }
}

class DevRevLogo extends StatelessWidget {
  const DevRevLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/devrev_logo.png',
            width: 25,
            height: 25,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 5),
          const Text(
            "DevRev",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

const List<List<String>> lottieAnimationAssets = [
  [
    "assets/animations/be_bold_animation.json",
    "assets/animations/say_hi.json",
    "assets/animations/developer_animation.json",
  ],
  [
    "assets/animations/lottie001.json",
    "assets/animations/lottie002.json",
    "assets/animations/say_hi.json",
  ],
  [
    "assets/animations/lottie003.json",
    "assets/animations/lottie004.json",
    "assets/animations/say_hi.json",
  ],
  [
    "assets/animations/lottie005.json",
    "assets/animations/developer_animation.json",
    "assets/animations/say_hi.json",
  ],
];

class MediaItems {
  static const List<String> images = [
    "assets/images/photo-001.jpeg",
    "assets/images/photo-002.jpeg",
    "assets/images/photo-003.jpeg",
  ];
  static const String lottieEmptyAsset = "assets/animations/lottie_empty.json";
}
