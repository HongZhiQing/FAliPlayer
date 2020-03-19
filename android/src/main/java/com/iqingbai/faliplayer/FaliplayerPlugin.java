package com.iqingbai.faliplayer;

import android.support.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


public class FaliplayerPlugin implements FlutterPlugin, MethodCallHandler {

    public FaliplayerPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("plugin.iqingbai.com/ali_video_play", new ShareFAliPlayerFactory(flutterPluginBinding.getBinaryMessenger()));
        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("plugin.iqingbai.com/ali_video_play_single_", new ShareFAliSinglePlayerFactory(flutterPluginBinding.getBinaryMessenger()));
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

}
