import 'package:faliplayer/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef PageBuilder = Widget Function(BuildContext context, int index);
typedef ThumbImageBuilder = Widget Function(
    BuildContext context, int index, int heigth, int width);
typedef VideoSizeBuild = Size Function(BuildContext context, int index);

var _defaultBuild = (c, i) => Container();

class FAliPlayerView extends StatefulWidget {
  final FAliListPlayerController controller;
  /// 构造视频上层UI
  final PageBuilder pageBuilder;
  /// 构造视频缩略图
  final ThumbImageBuilder thumbImageBuilder;
  /// 背景颜色
  final Color backgroundColor;
  /// Video宽高的回调
  final VideoSizeBuild videoSizeBuild;

  ///使用默认UI
  FAliPlayerView({
    Key key,
    this.controller,
    this.backgroundColor = Colors.black,
  })  : pageBuilder = _defaultBuild,
        thumbImageBuilder = null,
        videoSizeBuild = null,
        super(key: key);

  ///自定义pageUI
  FAliPlayerView.builder({
    this.controller,
    this.pageBuilder,
    this.thumbImageBuilder,
    this.backgroundColor = Colors.black,
    this.videoSizeBuild,
  });

  @override
  _FAliPlayerViewState createState() => _FAliPlayerViewState();
}

class _FAliPlayerViewState extends State<FAliPlayerView> {
  PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    ///  设置第一帧渲染成功回调
    ///  这样做的目的是为了不让切换视频的时候造成闪屏
    ///  在切换界面的时间pageController先收到回调
    ///  然后把视频列表切换到目标index的视频
    ///  [currentIndex]设置成当前播放的index,但是不[setState]
    ///  在切换完成并且第一帧已经渲染完成之后才setState
    widget.controller.setFirstRenderedStartListener(() {
      if (widget.controller.firstRenderedStart) {
        setState(() {});
        widget.controller.firstRenderedStart = false;
      }
    });

    _pageController.addListener(() {
      if (isIntegerForDouble(_pageController.page)) {
        double page = _pageController.page;
        if (page != currentIndex) {
          widget.controller.moveTo(page.toInt());
          currentIndex = page.toInt();
        }
      }
    });
    super.initState();
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
          body = VideoView(
            controller: widget.controller,
          );
        }
        var pageUi =
            widget.pageBuilder == null ? Container() : widget.pageBuilder(c, i);

        Widget thumbImage = widget.thumbImageBuilder != null
            ? widget.thumbImageBuilder(
                c, i, widget.controller.height, widget.controller.width)
            : Container();

        return Container(
          color: widget.backgroundColor,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              thumbImage,
              Offstage(
                  offstage: !(currentIndex == i),
                  child: Container(child: body)),
              pageUi,
            ],
          ),
        );
      },
      itemCount: widget.controller.urls.length,
    );
  }

  /// 判断double为整数
  bool isIntegerForDouble(double obj) {
    if (obj == 0) {
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
      creationParams: {
        "cacheConfig": widget.controller.cacheConfig?.toJson(),
        "loop": widget.controller.loop
      },
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
