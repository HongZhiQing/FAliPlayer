import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:faliplayer/faliplayer.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FAliListPlayerController controller;
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
    getTemporaryDirectory().then((d) {
      AVPCacheConfig config = new AVPCacheConfig();
      controller.setCacheConfig(
          AVPCacheConfig(path: d.path, maxDuration: 100, maxSizeMB: 1024));
    });
    //播放位置更新监听
    controller.setPositionUpdateListener((position) {

    });
    //缓存位置更新监听
    controller.setBufferedPositionUpdateListener((position) {

    });
    //视频大小变化监听
    controller.setOnVideoSizeChanged((){

    });
    //视频播放事件变化监听
    controller.setOnPlayEventListener((type){

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FAliPlayerView.builder(
          controller: controller,
          pageBuilder: (c, i) {
            return GestureDetector(
                onTap: () {
                  controller.pause();
                },
                onDoubleTap: () {
                  controller.start();
                },
                child:Container());
          },
          thumbImageBuilder: (c, i, h, w) {
            controller.start();
            controller.pause();
            controller.moveTo(0);
            controller.moveToNext();
            controller.moveToPre();
            return Container(
                color: Colors.black,
                constraints: BoxConstraints.expand(),
                child: Image.network(
                  "${urls[i]}?vframe/jpg/offset/1",
                  fit: BoxFit.cover,
                ));
          },
        ),

      ),
    );
  }
}
