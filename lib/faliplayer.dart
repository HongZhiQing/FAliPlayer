import 'dart:async';
import 'dart:math' as math;
import 'package:faliplayer/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AliPlayerView extends StatefulWidget {
  final List<String> urls;

  const AliPlayerView({Key key, this.urls}) : super(key: key);

  @override
  _AliPlayerViewState createState() => _AliPlayerViewState();
}

class _AliPlayerViewState extends State<AliPlayerView> {
  FAliListPlayerController _controller;
  PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = FAliListPlayerController(isAutoPlay: true);
    _controller.addUrls(widget.urls);
    _controller.setFirstRenderedStartListener(() {
      print('firstRenderedStart:${_controller.firstRenderedStart}');
      if (_controller.firstRenderedStart) {
        setState(() {});
        _controller.firstRenderedStart = false;
      }
    });
    _pageController.addListener(() {
      print('_pageController.page:${isIntegerForDouble(_pageController.page)}');
      if (isIntegerForDouble(_pageController.page)) {
        double page = _pageController.page;
        if (page != currentIndex) {
          _controller.moveTo(widget.urls[page.toInt()]);
          currentIndex = page.toInt();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemBuilder: (c, i) {
        Widget body = Container(
          color: Colors.black,
        );
        if (currentIndex == i) {
          body = VideoView(controller: _controller,);
        }
        return Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                color: Colors.black,
                child: Image.network("${widget.urls[i]}?vframe/jpg/offset/1"),
              ),
              Offstage(offstage: !(currentIndex == i), child: body),
            ],
          ),
        );
      },
      itemCount: _controller.urls.length,
      onPageChanged: (i) {
        print('i=$i === current=$currentIndex');
        if (i >= currentIndex + 2 || i <= currentIndex - 2) {
//          _controller.moveTo(widget.urls[i]);
//          Future.delayed(Duration(milliseconds: 150)).then((d) {
//            currentIndex = i;
//          });
        }
      },
    );
  }

  bool isIntegerForDouble(double obj) {
    if(obj==0){
      return true;
    }
    double eps = 1e-10; // 精度范围
    print('obj - (obj ~/ obj):${obj - (obj ~/ obj)}');
    return obj - obj.floor() < eps;
  }
}

class VideoView extends StatefulWidget {
  final FAliListPlayerController controller;

  const VideoView({Key key, this.controller}) : super(key: key);

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: "plugin.iqingbai.com/ali_video_play",
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: widget.controller.onViewCreate,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
