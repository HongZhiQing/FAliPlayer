import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

typedef FirstRenderedStartListener = Function();

///当前播放进度更新
typedef OnPositionUpdateListener = Function(int position);

///当前缓存进度更新
typedef OnBufferedPositionUpdateListener = Function(int position);

///大小改变回调
typedef OnVideoSizeChanged = void Function();

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
enum AVPStatus {
  ///空转，闲时，静态
  AVPStatusIdle,

  /// 初始化完成
  AVPStatusInitialzed,

  /// 准备完成
  AVPStatusPrepared,

  /// 正在播放
  AVPStatusStarted,

  /// 播放暂停
  AVPStatusPaused,

  /// 播放停止
  AVPStatusStopped,

  /// 播放完成
  AVPStatusCompletion,

  /// 播放错误
  AVPStatusError
}
enum AVPScalingMode {
  SCALETOFILL,
  SCALEASPECTFIT,
  SCALEASPECTFILL,
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

  ///播放列表的大小
  Map<String, Size> videoSizes;

  ///自动播放
  bool isAutoPlay;

  ///循环播放
  bool loop;

  ///标记第一帧渲染成功,每次都切换新的视频都会标记为true
  ///用到的地方需要手动标记为false，否则会一直为true
  bool firstRenderedStart = false;

  ///缓存配置
  AVPCacheConfig cacheConfig;

  ///当前视频的高
  int height;

  ///当前视频的宽
  int width;

  int currentStatus;

  ///第一帧渲染成功的监听器，每次切换新的视频都会调用
  FirstRenderedStartListener _firstRenderedStartListener;

  OnBufferedPositionUpdateListener _bufferedPositionUpdateListener;

  OnPositionUpdateListener _positionUpdateListener;

  OnVideoSizeChanged _onVideoSizeChanged;

  FAliListPlayerController(
      {this.isAutoPlay = false, this.cacheConfig, this.loop = false}) {
    urls = List();
  }

  /// 当前是否正在播放
  bool get isPlaying => currentStatus == AVPStatus.AVPStatusStarted.index;

  void setBufferedPositionUpdateListener(
      OnBufferedPositionUpdateListener value) {
    _bufferedPositionUpdateListener = value;
  }

  /// 设置当前播放位置监听
  void setPositionUpdateListener(OnPositionUpdateListener value) {
    _positionUpdateListener = value;
  }

  /// 设置首帧渲染完成的监听器
  setFirstRenderedStartListener(FirstRenderedStartListener listener) {
    this._firstRenderedStartListener = listener;
  }

  /// 设置视频宽高变化监听
  setOnVideoSizeChanged(OnVideoSizeChanged listener) {
    this._onVideoSizeChanged = listener;
  }

  /// 设置缓存配置,请在初始化时设置
  void setCacheConfig(AVPCacheConfig config) {
    this.cacheConfig = config;
  }

  /// 往视频播放列表添加预加载urls
  void addUrls(List<String> urls) {
    this.urls.addAll(urls);
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

  Future<void> setScalingMode(AVPScalingMode mode) {
    return _channel?.invokeMethod("setScalingMode", {
      "mode": mode.index,
    });
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
        if (event["values"] == AVPEventType.AVPEventFirstRenderedStart.index) {
//          firstRenderedStart = true;
        }
        break;
      case "onPlayerStatusChanged":
        currentStatus = event["values"];
        if (event["values"] == AVPStatus.AVPStatusStarted.index) {
          firstRenderedStart = true;
          if (width < height) {
            this.setScalingMode(AVPScalingMode.SCALEASPECTFILL);
          } else {
            this.setScalingMode(AVPScalingMode.SCALEASPECTFIT);
          }
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
      case "onVideoSizeChanged":
        this.height = event["height"];
        this.width = event["width"];
        if (this._onVideoSizeChanged != null) {
          this._onVideoSizeChanged();
        }
        break;
    }
  }

  void dispose() {
    _streamSubscription?.cancel();
  }

  void onViewCreate(int i) {
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
}
