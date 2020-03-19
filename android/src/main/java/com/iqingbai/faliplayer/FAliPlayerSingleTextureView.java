package com.iqingbai.faliplayer;

import android.content.Context;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.RequiresApi;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import com.aliyun.player.AliPlayer;
import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.bean.InfoBean;
import com.aliyun.player.nativeclass.CacheConfig;
import com.aliyun.player.nativeclass.PlayerConfig;
import com.aliyun.player.source.UrlSource;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FAliPlayerSingleTextureView implements PlatformView, MethodChannel.MethodCallHandler, IPlayer.OnStateChangedListener, IPlayer.OnPreparedListener, IPlayer.OnInfoListener, IPlayer.OnErrorListener {
    int viewId;
    private AliPlayer aliPlayer;
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private SurfaceView surfaceView;
    private CacheConfig cacheConfig;


    @RequiresApi(api = Build.VERSION_CODES.O)
    FAliPlayerSingleTextureView(Context context, BinaryMessenger messenger, HashMap args, int viewId) {
        createView(context, args);
        initChannel(messenger, viewId);
        this.viewId = viewId;
    }

    private void createView(Context context, HashMap args) {
        aliPlayer = AliPlayerFactory.createAliListPlayer(context);
        aliPlayer.setOnStateChangedListener(this);
        aliPlayer.setOnPreparedListener(this);
        aliPlayer.setOnInfoListener(this);
        aliPlayer.setOnErrorListener(this);
        UrlSource urlSource = new UrlSource();
        urlSource.setUri((String) args.get("url"));
        aliPlayer.setDataSource(urlSource);
        aliPlayer.setScaleMode(IPlayer.ScaleMode.SCALE_TO_FILL);


        HashMap map = (HashMap) args.get("cacheConfig");
        cacheConfig = new CacheConfig();
        //开启缓存功能
        cacheConfig.mEnable = true;
        //能够缓存的单个文件最a大时长。超过此长度则不缓存
        assert map != null;
        int maxDuration = (int) map.get("maxDuration");
        System.out.println("maxDuration:"+maxDuration);
        BigDecimal b = new BigDecimal(maxDuration);
        cacheConfig.mMaxDurationS = b.longValue();
        cacheConfig.mMaxSizeMB = (int) map.get("maxSizeMB");
        cacheConfig.mDir = (String) map.get("path");
        aliPlayer.setCacheConfig(cacheConfig);
        PlayerConfig config = aliPlayer.getConfig();
        //设置网络超时时间，单位ms
        config.mNetworkTimeout = 5000;
        //设置超时重试次数。每次重试间隔为networkTimeout。networkRetryCount=0则表示不重试，重试策略app决定，默认值为2
        config.mNetworkRetryCount = 2;
        surfaceView = new SurfaceView(context);
        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder surfaceHolder) {
                aliPlayer.setDisplay(surfaceHolder);
            }

            @Override
            public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
                aliPlayer.redraw();
            }

            @Override
            public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
                aliPlayer.setDisplay(null);
            }
        });
        aliPlayer.prepare();
    }

    private void initChannel(BinaryMessenger messenger, int viewId) {
        this.methodChannel = new MethodChannel(messenger, "plugin.iqingbai.com/ali_video_play_single_" + viewId);
        this.eventChannel = new EventChannel(messenger, "plugin.iqingbai.com/eventChannel/ali_video_play_single_" + viewId);
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
            case "start":
                aliPlayer.start();
                result.success(null);
                break;
            case "pause":
                aliPlayer.pause();
                result.success(null);
                break;
            case "stop":
                aliPlayer.stop();
                result.success(null);
                break;
            case "setMute":
                aliPlayer.setMute((Boolean) call.argument("mute"));
                result.success(null);
                break;

            case "seekTo":
                int position = call.argument("position");
                BigDecimal b = new BigDecimal(position);
                aliPlayer.seekTo(b.longValue());
                result.success(null);
                break;

//            case "setAutoPlay":
//                aliListPlayer.setAutoPlay((boolean) call.argument("auto"));
//                result.success(null);
//                break;
        }
    }

    @Override
    public void onStateChanged(int i) {
        System.out.println("onPlayerStatusChanged：" + i);
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("eventType", "onPlayerStatusChanged");
            map.put("values", i);
            eventSink.success(map);
        }
    }

    @Override
    public void onPrepared() {
        System.out.println("onPrepared：");

        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("eventType", "onPrepared");
            eventSink.success(map);
        }
    }

    @Override
    public void onInfo(InfoBean infoBean) {
        System.out.println("onInfo：" + infoBean);
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
        System.out.println("onError：" + errorInfo.getMsg());
        if (eventSink != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("eventType", "onError");
            map.put("msg", errorInfo.getMsg());
            map.put("errorCode", errorInfo.getCode());
            eventSink.success(map);
        }
    }
}
