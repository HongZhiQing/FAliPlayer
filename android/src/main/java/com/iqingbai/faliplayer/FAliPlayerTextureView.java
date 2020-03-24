package com.iqingbai.faliplayer;

import android.content.Context;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.RequiresApi;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import com.aliyun.player.AliListPlayer;
import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.bean.InfoBean;
import com.aliyun.player.bean.InfoCode;
import com.aliyun.player.nativeclass.CacheConfig;
import com.aliyun.player.nativeclass.PlayerConfig;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FAliPlayerTextureView implements PlatformView, MethodChannel.MethodCallHandler, IPlayer.OnStateChangedListener, IPlayer.OnPreparedListener, IPlayer.OnInfoListener, IPlayer.OnErrorListener, IPlayer.OnVideoSizeChangedListener {
    int viewId;
    private AliListPlayer aliListPlayer;
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private SurfaceView surfaceView;
    private CacheConfig cacheConfig;


    @RequiresApi(api = Build.VERSION_CODES.O)
    FAliPlayerTextureView(Context context, BinaryMessenger messenger, HashMap args, int viewId) {
        System.out.println("args:"+args.get("loop"));
        createView(context, args);
        initChannel(messenger, viewId);
        this.viewId = viewId;
    }


    private void createView(Context context, HashMap args) {
        aliListPlayer = AliPlayerFactory.createAliListPlayer(context);
        aliListPlayer.setOnStateChangedListener(this);
        aliListPlayer.setOnPreparedListener(this);
        aliListPlayer.setOnInfoListener(this);
        aliListPlayer.setOnErrorListener(this);
        aliListPlayer.setOnVideoSizeChangedListener(this);
        aliListPlayer.setPreloadCount(5);
        aliListPlayer.setAutoPlay(true);
        aliListPlayer.setScaleMode(IPlayer.ScaleMode.SCALE_TO_FILL);
        boolean loop = (boolean) args.get("loop");
        boolean auto = (boolean) args.get("auto");
        aliListPlayer.setLoop(loop);
        aliListPlayer.setAutoPlay(auto);


        HashMap map = (HashMap) args.get("cacheConfig");
        cacheConfig = new CacheConfig();
        //开启缓存功能
        cacheConfig.mEnable = true;
        //能够缓存的单个文件最a大时长。超过此长度则不缓存
        assert map != null;
        BigDecimal b = new BigDecimal((int)map.get("maxDuration"));
        cacheConfig.mMaxDurationS = b.longValue();
        cacheConfig.mMaxSizeMB = (int) map.get("maxSizeMB");
        cacheConfig.mDir = (String) map.get("path");
        aliListPlayer.setCacheConfig(cacheConfig);
        PlayerConfig config = aliListPlayer.getConfig();
        //设置网络超时时间，单位ms
        config.mNetworkTimeout = 5000;
        //设置超时重试次数。每次重试间隔为networkTimeout。networkRetryCount=0则表示不重试，重试策略app决定，默认值为2
        config.mNetworkRetryCount = 2;
        surfaceView = new SurfaceView(context);
        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder surfaceHolder) {
                aliListPlayer.setDisplay(surfaceHolder);
            }

            @Override
            public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
                aliListPlayer.redraw();
            }

            @Override
            public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
                aliListPlayer.setDisplay(null);
            }
        });
        aliListPlayer.prepare();
    }

    private void initChannel(BinaryMessenger messenger, int viewId) {
        this.methodChannel = new MethodChannel(messenger, "plugin.iqingbai.com/ali_video_play_" + viewId);
        this.eventChannel = new EventChannel(messenger, "plugin.iqingbai.com/eventChannel/ali_video_play_" + viewId);
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
            }
        });
        methodChannel.setMethodCallHandler(this);

    }

    @Override
    public View getView() {
        return surfaceView;
    }

    @Override
    public void dispose() {
        methodChannel = null;
        eventChannel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        System.out.println("call:" + call.method);
        switch (call.method) {
            case "addUrlSource":
                List<String> list = call.argument("urls");
                if (list != null) {
                    for (int i = 0; i < list.size(); i++) {
                        aliListPlayer.addUrl(list.get(i), list.get(i));
                    }
                }
                result.success(null);
                break;
            case "start":
                aliListPlayer.start();
                result.success(null);
                break;
            case "pause":
                aliListPlayer.pause();
                result.success(null);
                break;
            case "stop":
                aliListPlayer.stop();
                result.success(null);
                break;
            case "setMute":
                aliListPlayer.setMute((Boolean) call.argument("mute"));
                result.success(null);
                break;
            case "moveTo":
                String url = call.argument("url");
                aliListPlayer.moveTo(url);
                result.success(null);
                break;
            case "moveToNext":
                aliListPlayer.moveToNext();
                result.success(null);
                break;
            case "moveToPre":
                aliListPlayer.moveToPrev();
                result.success(null);
                break;
            case "seekTo":
                int position = call.argument("position");
                BigDecimal b = new BigDecimal(position);
                aliListPlayer.seekTo(b.longValue());
                result.success(null);
                break;
            case "setScalingMode":
                int a = (int) call.argument("mode");
                switch (a) {
                    case 1:
                        aliListPlayer.setScaleMode(IPlayer.ScaleMode.SCALE_ASPECT_FIT);
                        break;
                    case 2:
                        aliListPlayer.setScaleMode(IPlayer.ScaleMode.SCALE_ASPECT_FILL);
                        break;
                    case 0:
                        aliListPlayer.setScaleMode(IPlayer.ScaleMode.SCALE_TO_FILL);
                        break;
                }
                result.success(null);
                break;
            case "getCachesPath":
                result.success(aliListPlayer.getCacheFilePath((String) call.argument("url")));
                break;


//            case "setAutoPlay":
//                aliListPlayer.setAutoPlay((boolean) call.argument("auto"));
//                result.success(null);
//                break;
        }

    }

    @Override
    public void onStateChanged(int i) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("eventType", "onPlayerStatusChanged");
            map.put("values", i);
            eventSink.success(map);
        }
    }

    @Override
    public void onPrepared() {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("eventType", "onPrepared");
            eventSink.success(map);
        }
    }
/*  Unknown(-1),
    LoopingStart(0),
    BufferedPosition(1),
    CurrentPosition(2),
    AutoPlayStart(3),
    SwitchToSoftwareVideoDecoder(100),
    AudioCodecNotSupport(101),
    AudioDecoderDeviceError(102),
    VideoCodecNotSupport(103),
    VideoDecoderDeviceError(104),
    NetworkRetry(107),
    CacheSuccess(108),
    CacheError(109),
    LowMemory(110);     */

    @Override
    public void onInfo(InfoBean infoBean) {
        HashMap<String, Object> map = new HashMap<>();
        switch (infoBean.getCode().getValue()) {
            case 1:
                map.put("eventType", "onBufferedPositionUpdate");
                map.put("values", infoBean.getExtraValue());
                eventSink.success(map);
                break;
            case 2:
                map.put("eventType", "onCurrentPositionUpdate");
                map.put("values", infoBean.getExtraValue());
                eventSink.success(map);
                break;
        }
    }

    @Override
    public void onError(ErrorInfo errorInfo) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("eventType", "onError");
            map.put("msg", errorInfo.getMsg());
            map.put("errorCode", errorInfo.getCode());
            eventSink.success(map);
        }
    }


    @Override
    public void onVideoSizeChanged(int i, int i1) {
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("eventType", "onVideoSizeChanged");
            map.put("width", i);
            map.put("height", i1);
            eventSink.success(map);
        }
    }
}
