import 'dart:async';

import 'package:faliplayer/faliplayer.dart';
import 'package:flutter/services.dart';




class FAliPlayerController {
  MethodChannel _channel;
  StreamSubscription _streamSubscription;

  ///自动播放
  bool isAutoPlay;

  ///循环播放
  bool loop;

  ///缓存配置
  AVPCacheConfig cacheConfig;

  ///标记第一帧渲染成功,每次都切换新的视频都会标记为true
  ///用到的地方需要手动标记为false，否则会一直为true
  bool firstRenderedStart = false;

  ///第一帧渲染成功的监听器，每次切换新的视频都会调用
  FirstRenderedStartListener _firstRenderedStartListener;

  OnBufferedPositionUpdateListener _bufferedPositionUpdateListener;

  OnPositionUpdateListener _positionUpdateListener;

  void setBufferedPositionUpdateListener(
      OnBufferedPositionUpdateListener value) {
    _bufferedPositionUpdateListener = value;
  }

  void setPositionUpdateListener(OnPositionUpdateListener value) {
    _positionUpdateListener = value;
  }

  FAliPlayerController({this.isAutoPlay = false,this.cacheConfig, this.loop = false});


  onViewCreate(int i) {
      _channel = MethodChannel("plugin.iqingbai.com/ali_video_play_single_$i");
      _streamSubscription = EventChannel(
              "plugin.iqingbai.com/eventChannel/ali_video_play_single_$i")
          .receiveBroadcastStream()
          .listen(_onEvent);
      if (isAutoPlay) {
        this.start();
    }
  }

  setFirstRenderedStartListener(FirstRenderedStartListener listener) {
    this._firstRenderedStartListener = listener;
  }

  /// 设置缓存配置,请在初始化时设置
  void setCacheConfig(AVPCacheConfig config) {
    this.cacheConfig = config;
    print('cacheConfig:${cacheConfig.path}');
  }

  ///开始播放
  Future<void> start() {
    return _channel?.invokeMethod("start");
  }

  ///暂停
  Future<void> pause() {
    return _channel?.invokeMethod("pause");
  }

  ///获取缓存文件的路径
  ///[url]文件的url
  Future<void> getCachePath(String url) {
    return _channel?.invokeMethod("getCachesPath");
  }

  ///设置是否静音
  Future<void> setMute(bool mute) {
    return _channel?.invokeMethod("setMute", {"mute": mute});
  }

  ///设置跳转进度
  Future<void> seekTo(int position) {
    return _channel?.invokeMethod("seekTo", {"seekTo": position});
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
