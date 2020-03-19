import 'dart:async';

import 'package:flutter/services.dart';

enum AVPEventType {
  ///准备完成事件*/
  AVPEventPrepareDone,

  ///自动启播事件*/
  AVPEventAutoPlayStart,

  ///首帧显示事件*/
  AVPEventFirstRenderedStart,

  ///播放完成事件*/
  AVPEventCompletion,

  ///缓冲开始事件*/
  AVPEventLoadingStart,

  ///缓冲完成事件*/
  AVPEventLoadingEnd,

  ///跳转完成事件*/
  AVPEventSeekEnd,

  ///循环播放开始事件*/
  AVPEventLoopingStart,
}
typedef FirstRenderedStartListener = Function();
class FAliListPlayerController {
  MethodChannel _channel;
  StreamSubscription _streamSubscription;
  List<String> urls;
  bool isAutoPlay;
  bool firstRenderedStart = false;
  FirstRenderedStartListener firstRenderedStartListener;

  FAliListPlayerController({this.isAutoPlay = false}) {
    urls = List();
  }

  void addUrls(List<String> urls) {
    this.urls.addAll(urls);
  }

  onViewCreate(int i) {
    if (_channel == null && _streamSubscription == null) {
      _channel = MethodChannel("plugin.iqingbai.com/ali_video_play_0");

      _streamSubscription =
          EventChannel("plugin.iqingbai.com/eventChannel/ali_video_play_0")
              .receiveBroadcastStream()
              .listen(_onEvent);

      _channel.invokeMethod("addUrlSource", <String, dynamic>{"urls": urls});
      if (isAutoPlay || urls.length > 0) {
        this.moveTo(urls[0]);
      }
    }
  }

  setFirstRenderedStartListener(FirstRenderedStartListener listener){
    this.firstRenderedStartListener = listener;
  }

  ///开始播放
  Future<void> start() {
    return _channel?.invokeMethod("start");
  }

  ///暂停
  Future<void> pause() {
    return _channel?.invokeMethod("pause");
  }

  ///移到下一个
  Future<void> moveToNext() {
    return _channel?.invokeMethod("moveToNext");
  }

  ///移到上一个
  Future<void> moveToPre() {
    return _channel?.invokeMethod("moveToPre");
  }

  ///移动到目标视频，并播放
  ///[url]是视频的标识
  Future<void> moveTo(String url) {
    return _channel?.invokeMethod("moveTo", {
      "url": url,
    });
  }

  void _onEvent(event) {
    String type = event['eventType'];
    switch (type) {
      case "onPlayerEvent":
        print('event:${event["values"]}');
        if (event["values"] == AVPEventType.AVPEventFirstRenderedStart.index) {
//          firstRenderedStart = true;
        }
        break;
      case "onPlayerStatusChanged":
        print('onPlayerStatusChanged:${event["values"]}');
        if (event["values"] == 3) {
          firstRenderedStart = true;
          this.firstRenderedStartListener();
        }
        break;
    }
  }

  void dispose() {
    _streamSubscription.cancel();
  }
}
