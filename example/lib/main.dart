import 'package:flutter/material.dart';

import 'package:faliplayer/faliplayer.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FAliListPlayerController controller;
  bool a = true;
  List<String> urls = [
    "http://video.iqingbai.com/202002181038474liyNnnSzz.mp4",
    "http://video.iqingbai.com/20200218025702PSiVKDB5ap.mp4",
    "http://video.iqingbai.com/v0200f010000bpoujm68qblf351u7kqg.MP4",
    "http://video.iqingbai.com/v0200f230000bpoos459688r4f4ktnq0.MP4",
    "http://video.iqingbai.com/v0200fd60000bpouklebn5vab8nv6es0.MP4",
    "http://video.iqingbai.com/v0200fa00000bpnf14kmavfcq3piinkg.MP4",
    "http://video.iqingbai.com/v0200f9a0000bpkr35j2ap9cj5gjvlqg.MP4",
    "http://video.iqingbai.com/v0200f8a0000bpou2mnu9qbego7fpu0g.MP4",
    "http://video.iqingbai.com/v0200f8a0000bpoth05ds13erv5id0q0.MP4",
    "http://video.iqingbai.com/v0200f8a0000bport5nu9qbego7dimhg.MP4",
    "http://video.iqingbai.com/v0200f7a0000bpkcgvsuatl02d672cv0.MP4",
    "http://video.iqingbai.com/v0200f660000bpo8shqgd9fp1sds10k0.MP4",
    "http://video.iqingbai.com/v0200f530000bporepf3cp5e6ui4g5og.MP4",
    "http://video.iqingbai.com/v0200f530000bpob7ksm7fic1j4pi090.MP4",
  ];

  @override
  void initState() {
    super.initState();
    controller = FAliListPlayerController(isAutoPlay: true, loop: true);
    controller.addUrls(urls);
    controller.setCacheConfig(
        AVPCacheConfig(path: "hjhh", maxDuration: 100, maxSizeMB: 1024));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FAliListPlayerView.builder(
          controller: controller,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print('111111');
          },
        ),
      ),
    );
  }
}
