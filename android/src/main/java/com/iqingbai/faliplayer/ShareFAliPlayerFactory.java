package com.iqingbai.faliplayer;

import android.content.Context;
import android.os.Build;
import android.support.annotation.RequiresApi;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class ShareFAliPlayerFactory extends PlatformViewFactory {
    private BinaryMessenger messenger;
    private FAliPlayerTextureView fAliPlayerTextureView;

    ShareFAliPlayerFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        if (fAliPlayerTextureView == null)
            fAliPlayerTextureView = new FAliPlayerTextureView(context, messenger, (HashMap) args, viewId);
        return fAliPlayerTextureView;
    }
}
