import 'dart:async';

import 'package:flutter/services.dart';

typedef FirstRenderedStartListener = Function();

///当前播放进度更新
typedef OnPositionUpdateListener = Function(int position);

///当前缓存进度更新
typedef OnBufferedPositionUpdateListener = Function(int position);

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

class AVPCacheConfig {
  ///缓存目录
  final String path;

  ///单位秒
  final int maxDuration;

  ///单位M
  final int maxSizeMB;

  AVPCacheConfig({this.path, this.maxDuration, this.maxSizeMB});

  Map<String, dynamic> toJson() =>
      {"path": path, "maxDuration": maxDuration, "maxSizeMB": maxSizeMB};
}

class FAliListPlayerController {
  MethodChannel _channel;
  StreamSubscription _streamSubscription;

  ///播放列表的URL组
  List<String> urls;

  ///自动播放
  bool isAutoPlay;

  ///标记第一帧渲染成功,每次都切换新的视频都会标记为true
  ///用到的地方需要手动标记为false，否则会一直为true
  bool firstRenderedStart = false;

  ///缓存配置
  AVPCacheConfig cacheConfig;

  ///第一帧渲染成功的监听器，每次切换新的视频都会调用
  FirstRenderedStartListener _firstRenderedStartListener;

  OnBufferedPositionUpdateListener _bufferedPositionUpdateListener;

  OnPositionUpdateListener _positionUpdateListener;

  set setBufferedPositionUpdateListener(
      OnBufferedPositionUpdateListener value) {
    _bufferedPositionUpdateListener = value;
  }

  set setPositionUpdateListener(OnPositionUpdateListener value) {
    _positionUpdateListener = value;
  }

  FAliListPlayerController({this.isAutoPlay = false, this.cacheConfig}) {
    urls = List();
  }

  void setCacheConfig(AVPCacheConfig config) {
    this.cacheConfig = config;
  }

  void addUrls(List<String> urls) {
    this.urls.addAll(urls);
  }

  onViewCreate(int i) {
    if (_channel == null && _streamSubscription == null) {
      _channel = MethodChannel("plugin.iqingbai.com/ali_video_play_$i");

      _streamSubscription =
          EventChannel("plugin.iqingbai.com/eventChannel/ali_video_play_$i")
              .receiveBroadcastStream()
              .listen(_onEvent);

      _channel.invokeMethod("addUrlSource", <String, dynamic>{"urls": urls});
      if (isAutoPlay || urls.length > 0) {
        this.moveTo(0);
      }
    }
  }

  setFirstRenderedStartListener(FirstRenderedStartListener listener) {
    this._firstRenderedStartListener = listener;
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
  ///[index]是视频的标识坐标
  Future<void> moveTo(int index) {
    return _channel?.invokeMethod("moveTo", {
      "url": urls[index],
    });
  }

  ///获取缓存文件的路径
  ///[url]文件的url
  Future<void> getCachePath(String url) {
    return _channel?.invokeMethod("getCachesPath");
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
          this._firstRenderedStartListener();
        }
        break;
      case "onCurrentPositionUpdate":
        if (this._positionUpdateListener != null) {
          this._positionUpdateListener(event["values"]);
        }
        break;
      case "onBufferedPositionUpdate":
        if (this._bufferedPositionUpdateListener != null) {
          this._bufferedPositionUpdateListener(event["values"]);
        }
        break;
    }
  }

  void dispose() {
    _streamSubscription.cancel();
  }
}
